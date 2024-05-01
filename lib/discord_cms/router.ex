defmodule DiscordCms.Router do
  @template_dir "lib/discord_cms/templates"

  # import Plug.Conn
  use Plug.Router
  alias Nostrum.Cache
  alias Nostrum.Api
  alias DiscordCms.MessageCache

  plug(:match)
  plug(:dispatch)

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
      conn
      |> put_resp_content_type("text/html")
      # |> send_resp(200, content)
      |> send_resp(200, """
      <!doctype html>
      <html>
      <head>
      <meta charset="utf-8"/>
      <title>#{channel}.md</title>
      </head>
      <body>
      <div id="content"></div>
      <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
      <script>
      document.getElementById('content').innerHTML =
      marked.parse(#{Poison.encode!(content)});
      </script>
      </body>
      </html>
      """)
    end
  end

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Not found")
  end
end
