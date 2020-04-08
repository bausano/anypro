defmodule AnyproWeb.CoachController do
  use AnyproWeb, :controller

  alias Anypro.Coach
  alias Anypro.Repo

  # The expected request JSON which is sent to the store webhook.
  @typeform_store_schema %{
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

  def store(conn, params) do
    # TODO: Do validation as a middleware.
    case ExJsonSchema.Validator.validate(@typeform_store_schema, params) do
      {:error, errors} ->
        IO.inspect errors
        IO.inspect params
        send_resp(conn, 422, "")
      :ok ->
        answers = params["form_response"]["answers"]

        # Finds the answer which matches given ref. We set up refs in the
        # typeform UI. The map_res is either a map or an atom :error.
        answer_for_field = fn map_res, ref, type ->
          case map_res do
            :error -> :error
            map ->
              answer = Enum.find(answers, fn a -> a["field"]["ref"] == ref end)
              case answer do
                nil -> :error
                # Gets the answer value based on the provided type. For example, for
                # a phone number, the type would be "phone_number" whereas for name
                # it would be "text".
                a -> Map.put(map, ref, a[type])
              end
          end
        end

        # Gets all required fields from the form. If any field is missing, the
        # coach will be equal to atom :error.
        coach = Map.new()
        |> answer_for_field.("bio", "text")
        |> answer_for_field.("email", "email")
        |> answer_for_field.("name", "text")
        |> answer_for_field.("pga_qualified", "boolean")
        |> answer_for_field.("phone", "phone_number")
        |> answer_for_field.("pricing", "text")
        |> answer_for_field.("profile_picture", "file_url")

        case coach do
          :error -> send_resp(conn, 422, "")
          coach ->
            coach = coach
            |> Map.put("slug", Coach.slugified_name(coach["name"]))
            # Maps all string keys to atoms.
            |> Map.new(fn {k, v} -> { String.to_atom(k), v } end)

            case Repo.insert Coach.changeset(%Coach{}, coach) do
              {:ok, _} -> send_resp(conn, :created, "")
              # TODO: Handle all kinds of errors and don't coerce them to 409.
              {:error, error} ->
                IO.inspect error
                send_resp(conn, :conflict, "")
            end
        end
    end
  end
end
