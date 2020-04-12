defmodule AnyproWeb.Plugs.Typeform do
  import Plug.Conn

  # The expected request JSON which is sent to typeform webhooks.
  @typeform_schema %{
    "type" => "object",
    "required" => ["form_response"],
    "properties" => %{
      "form_response" => %{
        "type" => "object",
        "required" => ["answers"],
        "properties" => %{
          "answers" =>  %{"items" => %{
            "type" => "object",
            "required" => ["field"],
            "properties" => %{
              "email" => %{"type" => "string"},
              "phone_number" => %{"type" => "string"},
              "text" => %{"type" => "string"},
              "file_url" => %{"type" => "string"},
              "boolean" => %{"type" => "boolean"},
              "field" => %{
                "type" => "object",
                "required" => ["ref"],
                "properties" => %{
                  "ref" => %{"type" => "string"}
                }
              }
            }
          }}
        }
      }
    }
  } |> ExJsonSchema.Schema.resolve()


  # TODO: Use the example init function at https://hexdocs.pm/phoenix/plug.html
  # to implement token checking.
  def init([]), do: false

  def call(%Plug.Conn{params: params} = conn, _init) do
    case ExJsonSchema.Validator.validate(@typeform_schema, params) do
      {:error, errors} ->
        # TODO: Some logging would be nice here instead of printing into the
        # console. Since this scenario after we implement the token checking is
        # going to be breaking, maybe even trigger a webhook.
        IO.puts
        IO.inspect errors
        IO.inspect params
        conn
        |> send_resp(:unprocessable_entity, "")
        |> halt()
      :ok ->
        assign(conn, :answers, params["form_response"]["answers"])
    end
  end
end
