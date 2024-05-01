defmodule DiscordCms.Router do
  @template_dir "lib/discord_cms/templates"

  # import Plug.Conn
  import Logger
  use Plug.Router
  alias Nostrum.Cache
  alias Nostrum.Api
  alias DiscordCms.MessageCache

  plug Plug.Static, at: "/static", from: "priv/static"


  plug(:match)
  plug(:dispatch)

  defp first_level_1_header([{"h1", _, [content], %{}} | _] = ast) do
    content
  end

  defp first_level_1_header([_ | rest]), do: first_level_1_header(rest)
  defp first_level_1_header([]), do: ""

  defp render(%{status: status} = conn, template, assigns \\ []) do
    body =
      @template_dir
      |> Path.join(template)
      |> String.replace_suffix(".html", ".heex")
      |> EEx.eval_file(assigns)

    send_resp(conn, status || 200, body)
  end

  get "/attachments/:id/:filename" do
    # send file at attachments/id.filename

    mimeType = MIME.from_path(filename)

    conn
    |> put_resp_content_type(mimeType)
    |> put_req_header("Cache-Control", "public, max-age=31536000")
    |> send_file(200, "attachments/#{id}.#{filename}")
  end

  get "/:category/:channel.md" do
    {status, content} = MessageCache.get(channel)

    if status == :error do
      conn
      |> put_resp_content_type("text/plain")
      |> send_resp(404, "Not found")
    else
      ast = case Earmark.Parser.as_ast(content) do
            {:ok, ast, _} -> ast
            {:error, _, _errs} -> conn |> send_resp(500, "Internal server error"); nil
      end

      title = first_level_1_header(ast)
      html = Earmark.as_html!(content, escape: false)

      conn
      |> render("markdown.heex", content: html, title: title)
    end
  end

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Not found")
  end
end
