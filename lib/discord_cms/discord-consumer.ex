defmodule DiscordConsumer do
  import Logger
  use Nostrum.Consumer

  # alias Nostrum.Api

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    # print message content to console
    channel_id = msg.channel_id
  end

  def handle_event({:MESSAGE_UPDATE, msg, _ws_state}) do
    # print message content to console
    Logger.debug("Edit message: #{inspect(msg)}")
    # todo: invalidate content cache
  end

  def handle_event({:MESSAGE_DELETE, msg, _ws_state}) do
    # print message content to console
    Logger.debug("Delete message: #{inspect(msg)}")
    # todo: invalidate content cache
  end
end
