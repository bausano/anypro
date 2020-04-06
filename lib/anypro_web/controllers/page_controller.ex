defmodule AnyproWeb.PageController do
  use AnyproWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
