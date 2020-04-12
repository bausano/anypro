defmodule AnyproWeb.CoachControllerTest do
  use AnyproWeb.ConnCase

  @valid_body %{
    "form_response" => %{
      "answers" => [
        %{
          "email" => "test@example.com",
          "field" => %{
            "ref" => "email"
          }
        },
        %{
          "text" => "Lorem ipsum dolor",
          "field" => %{
            "ref" => "name"
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
    assert response(conn, :unprocessable_entity)
  end

  test "POST /api/coaches empty answers array", %{conn: conn} do
    conn = post(conn, "/api/coaches", %{
      "form_response" => %{
        "answers" => []
      }
    })
    assert response(conn, :unprocessable_entity)
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
    assert response(conn, :unprocessable_entity)
  end

  test "POST /api/coaches and GET /{slug}", %{conn: conn} do
    conn = post(conn, "/api/coaches", @valid_body)
    assert response(conn, :created)

    # Gets the location where the coach profile has been created.
    location = Enum.find(
      conn.resp_headers,
      fn header ->
        {name, _} = header
        name == "location"
      end
    )
    assert location != nil
    {"location", coach_profile_url} = location
    # Grabs the html of the coach profile.
    conn = get(conn, coach_profile_url)
    assert conn.status == 200
    assert conn.resp_body =~ conn.assigns.coach.name
  end

  test "POST /api/coaches cannot create duplicate emails", %{conn: conn} do
    conn = post(conn, "/api/coaches", @valid_body)
    assert response(conn, :created)
    conn = post(conn, "/api/coaches", @valid_body)
    assert json_response(conn, :conflict) == %{
      "error" => "email_in_use",
      "message" => "This email address is already in use."
    }
  end

  test "POST /api/coaches can have duplicate names", %{conn: conn} do
    conn = post(conn, "/api/coaches", @valid_body)
    assert response(conn, :created)

    # We change the email for the second call.
    body = update_in(
      @valid_body["form_response"]["answers"],
      fn answers ->
        [%{
          "email" => "another-test@example.com",
          "field" => %{
            "ref" => "email"
          }
        }] ++ List.delete_at(answers, 0)
      end
    )
    conn = post(conn, "/api/coaches", body)
    assert response(conn, :created)
  end

  test "GET /{slug} returns 404 if coach does not exist", %{conn: conn} do
    conn = get(conn, "/this-slug-does-not-exist")
    assert conn.status == 404
    assert conn.resp_body =~ "Looks like this link is broken"
  end
end
