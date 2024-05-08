defmodule DiscordCms.Router do
  @template_dir "lib/discord_cms/templates"

  use Plug.Router
  alias DiscordCms.MessageCache

  plug(Plug.Static, at: "/static", from: "priv/static")

  plug(:match)
  plug(:dispatch)

  defp first_level_1_header([{"h1", _, [content], %{}} | _] = _) do
    content
  end

  defp first_level_1_header([_ | rest]), do: first_level_1_header(rest)
  defp first_level_1_header([]), do: ""

  defp render(%{status: status} = conn, template, assigns) do
    body =
      @template_dir
      |> Path.join(template)
      |> EEx.eval_file(assigns)

    title = assigns[:title] || "Sagar Patil"

    layout =
      @template_dir
      |> Path.join("layout.html.eex")
      |> EEx.eval_file(title: title, inner: body)

    send_resp(conn, status || 200, layout)
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
    {status, content} = MessageCache.get(channel, category)

    cond do
      status == :error ->
        conn
        |> put_resp_content_type("text/plain")
        |> send_resp(404, "Not found")
      true ->
        ast =
          case Earmark.Parser.as_ast(content) do
            {:ok, ast, _} ->
              ast

            {:error, _, _errs} ->
              conn |> send_resp(500, "Internal server error")
              nil
          end

        title = first_level_1_header(ast)
        html = Earmark.as_html!(content, escape: false)

        conn
        |> render(category <> "/page.html.eex", title: title, content: html)
    end
  end

  match _ do
    conn
    |> put_resp_content_type("text/plain")
    |> send_resp(404, "Not found")
  end
end
