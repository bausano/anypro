defmodule AnyproWeb.CoachControllerTest do
  use AnyproWeb.ConnCase

  test "POST /api/coaches", %{conn: conn} do
    conn = post(conn, "/api/coaches")
    assert response(conn, :created)
  end
end
