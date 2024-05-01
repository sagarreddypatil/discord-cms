defmodule DiscordCms.MessageCache do
  require Logger
  @my_guild_id 1_225_542_172_066_058_281

  def setup() do
    :ets.new(:channel_cache, [
      :set,
      :public,
      :named_table,
      read_concurrency: true
    ])
  end

  def get_cid(channel_name) do
    guild = Nostrum.Cache.GuildCache.get!(@my_guild_id)

    dchannel =
      guild.channels
      |> Enum.find(fn {_, c} -> c.name == channel_name end)

    if dchannel == nil do
      {:error, :not_found}
    else
      {cid, _} = dchannel
      {:ok, cid}
    end
  end

  def process_attachment(attachment) do
    # download attachment
    # store attachment
    # return path

    id = attachment.id
    filename = attachment.filename
    uri = attachment.url

    # check if file already exists
    if File.exists?("attachments/#{id}.#{filename}") do
      {:ok, "/attachments/#{id}/#{filename}"}
    else
      Logger.info("Downloading attachment #{filename} from #{uri}")

      case HTTPoison.get(uri) do
        {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
          File.write("attachments/#{id}.#{filename}", body)
          {:ok, "/attachments/#{id}/#{filename}"}

        {:ok, %HTTPoison.Response{status_code: 404}} ->
          {:error, :not_found}

        {:error, reason} ->
          {:error, reason}
      end
    end
  end

  def msg_to_markdown(msg) do
    attachments =
      msg.attachments
      |> Enum.map(&process_attachment/1)
      |> Enum.filter(fn
        {:ok, _} -> true
        _ -> false
      end)
      |> Enum.map(fn {:ok, path} -> path end)
      |> Enum.map(fn path -> "![](#{path})" end)
      |> Enum.join("")

    content = msg.content |> String.trim()
    content = if content == "" do "" else "#{content}\n\n" end

    if attachments != [] do
      "#{attachments}\n#{content}"
    else
      "#{content}"
    end
  end

  def to_markdown(messages) do
    messages
    |> Enum.map(&msg_to_markdown/1)
    |> Enum.join("")
    |> String.trim()
  end

  def get(channel_name) do
    case :ets.lookup(:channel_cache, channel_name) do
      [] ->
        {status, cid} = get_cid(channel_name)

        if status == :error do
          :ets.insert(:channel_cache, {channel_name, {:error, :not_found}})
          {:error, :not_found}
        else
          Logger.info("#{channel_name} not found in cache, fetching messages.")
          t = Task.async(fn -> Nostrum.Api.get_channel_messages!(cid, :infinity, {}) end)

          messages =
            Task.await(t)
            |> Enum.reverse()
            |> to_markdown()

          :ets.insert(:channel_cache, {channel_name, {:ok, messages}})
          {:ok, messages}
        end

      [{_, content}] ->
        content
    end
  end
end
