defmodule AnyproWeb.CoachController do
  use AnyproWeb, :controller

  def store(conn, params) do
    inspect params
    conn
    |> send_resp(:created, "")
  end
end
