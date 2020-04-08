defmodule AnyproWeb.CoachControllerTest do
  use AnyproWeb.ConnCase

  @valid_body %{
    "form_response" => %{
      "answers" => [
        %{
          "text" => "Lorem ipsum dolor",
          "field" => %{
            "ref" => "name"
          }
        },
        %{
          "email" => "test@example.com",
          "field" => %{
            "ref" => "email"
          }
        },
        %{
          "phone_number" => "+123456",
          "field" => %{
            "ref" => "phone"
          }
        },
        %{
          "text" => "Lorem ipsum dolor",
          "field" => %{
            "ref" => "bio"
          }
        },
        %{
          "boolean" => true,
          "field" => %{
            "ref" => "pga_qualified"
          }
        },
        %{
          "file_url" => "https://dummyimage.com/600x400/000/fff",
          "field" => %{
            "ref" => "profile_picture"
          }
        },
        %{
          "text" => "$10",
          "field" => %{
            "ref" => "pricing"
          }
        }
      ]
    }
  }

  test "POST /api/coaches empty request", %{conn: conn} do
    conn = post(conn, "/api/coaches", %{})
    assert response(conn, 422)
  end

  test "POST /api/coaches empty answers array", %{conn: conn} do
    conn = post(conn, "/api/coaches", %{
      "form_response" => %{
        "answers" => []
      }
    })
    assert response(conn, 422)
  end

  test "POST /api/coaches required fields are missing", %{conn: conn} do
    conn = post(conn, "/api/coaches", %{
      "form_response" => %{
        "answers" => [
          %{
            "text" => "Lorem ipsum dolor",
            "field" => %{
              "ref" => "name"
            }
          },
        ]
      }
    })
    assert response(conn, 422)
  end

  test "POST /api/coaches", %{conn: conn} do
    conn = post(conn, "/api/coaches", @valid_body)
    assert response(conn, :created)
  end

  test "POST /api/coaches creates duplicate", %{conn: conn} do
    conn = post(conn, "/api/coaches", @valid_body)
    assert response(conn, :conflict)
  end
end
