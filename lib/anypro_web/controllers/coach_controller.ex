defmodule AnyproWeb.CoachController do
  use AnyproWeb, :controller

  # Imports the "last" function.
  import Ecto.Query

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

  # Views a coach profile.
  def show(conn, %{"slug" => slug}) do
    case Repo.one(from c in Coach, where: c.slug == ^slug) do
      coach when is_map(coach) ->
        render conn, "show.html", coach: coach
      _ ->
        # TODO: Make a 404 page.
        text conn "404"
    end
  end

  # Inserts a new coach into the database.
  def store(conn, params) do
    # TODO: Do validation as a middleware.
    case ExJsonSchema.Validator.validate(@typeform_store_schema, params) do
      {:error, errors} ->
        IO.inspect errors
        IO.inspect params
        send_resp(conn, :unprocessable_entity, "")
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
          :error -> send_resp(conn, :unprocessable_entity, "")
          coach ->
            insert_coach_with_unique_slug(
              conn,
              Coach.slugified_name(coach["name"]),
              # Don't put any prefix to the slug initially and hope it's unique.
              "",
              # Maps all string keys to atoms.
              Map.new(coach, fn {k, v} -> { String.to_atom(k), v } end)
            )
        end
    end
  end

  # This function can be called recursivelly until a unique slug is
  # found. It concats strings `slug` and `slug_suffix`, sets them as
  # :slug field into the provideded coach map and tries to insert it.
  # If an error about uniqueness of the slug is returned, it calls
  # itself with `slug_prefix` being equal to "-${next_primary_id}".
  defp insert_coach_with_unique_slug(conn, slug, slug_suffix, coach_without_slug) do
    coach = Map.put(coach_without_slug, :slug, slug <> slug_suffix)
    case Repo.insert Coach.changeset(%Coach{}, coach) do
      # TODO: Trigger webhook.
      {:ok, record} ->
        location = AnyproWeb.Endpoint.url() <> "/" <> record.slug
        conn
        |> put_resp_header("location", location)
        |> send_resp(:created, "")
      # TODO: Handle all kinds of errors and don't coerce them to 409.
      {:error, changeset} ->
        case List.first(changeset.errors) do
          # Email already taken. This is a big problem which we cannot
          # ready deal with due to using typeform.
          # TODO: Send some kind of notification to us about this error.
          # TODO: Return an error message in the body.
          {:email, _} -> send_resp(conn, :conflict, "")
          # Slug already exists, we will append an id to it.
          {:slug, _} ->
            # Take current max coach id, increments it by 1 and stringifies it.
            next_id = Coach
            |> last
            |> Repo.one
            |> (fn record -> record.id + 1 end).()
            |> Integer.to_string

            # Call itself but this time with a slug prefix.
            insert_coach_with_unique_slug(
              conn,
              slug,
              "-" <> next_id,
              coach_without_slug
            )
        end
    end
  end
end
