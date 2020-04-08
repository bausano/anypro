# Anypro

## Running in docker
We're using [this guide][docker-with-phoenix] to set up a testing environment in
which our Phoenix app talks to Docker.

Use `docker-compose up --abort-on-container-exit` to create the container. Tests
can be run in the container with `docker-compose run anypro mix test`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Typeform
We use [Typeform][typeform] for the UI. Users fill out forms and the Typeform
app sends webhooks to our endpoints. In their forms, we can set up references to
fields and access information via the references.

A webhook will receive payload along lines of
```json
{
  "event_id": "01E5DECSHRZRTJ6BT9KZ0PJNKF",
  "event_type": "form_response",
  "form_response": {
    "form_id": "lx4NPZ",
    "token": "01E5DECSHRZRTJ6BT9KZ0PJNKF",
    "landed_at": "2020-04-08T17:46:21Z",
    "submitted_at": "2020-04-08T17:46:21Z",
    "definition": {
      "id": "lx4NPZ",
      "title": "Signup as a Pro (staging)",
      "fields": [
        {
          "id": "gOlat0OXkLJm",
          "title": "What's your name?",
          "type": "short_text",
          "ref": "name",
          "properties": {}
        }
      ]
    },
    "answers": [
      {
        "type": "text",
        "text": "Lorem ipsum dolor",
        "field": {
          "id": "gOlat0OXkLJm",
          "type": "short_text",
          "ref": "name"
        }
      }
    ]
  }
}
```

Generally, we are going to be interested in following fields.
- `.form_response.form_id` to assert that we are working with a form we expect.
- `.form_response.answers.[].field.ref` will give a reference for each field
  which we can set up in their UI.
- `.form_response.answers.[].text` is an arbitrary text.
- `.form_response.answers.[].boolean` is a JSON boolean.
- `.form_response.answers.[].phone_number` is a string with a phone number.
- `.form_response.answers.[].email` is a string with an email.
- `.form_response.answers.[].file_url` will be a Typeform API url with an
  uploaded file.

## New database table
To set up new database table, refer to [this Ecto tutorial][ecto-new-table]. For
list of database fields refer to the [documentation here][ecto-types]. The
primary key column named `id` is created by default.

## Postgres
You can list all databases with `\l`. Then connect to a database with
`\c {db_name}`. To list database tables use `\dt`. `\d+ {table_name}` prints the
structure of a table.

## Useful references
- [Building a JSON API with Phoenix 1.3 and Elixir][building-json-api]
- [Elixir JSON Schema validator][validate-json-schema]

<!-- Invisible List of References -->
[docker-with-phoenix]: https://github.com/fireproofsocks/phoenix-docker-compose
[typeform]: https://www.typeform.com
[ecto-new-table]: https://hexdocs.pm/phoenix/ecto.html
[ecto-types]: https://hexdocs.pm/ecto/Ecto.Type.html#types
[building-json-api]: https://dev.to/lobo_tuerto/building-a-json-api-with-phoenix-13-and-elixir-ooo
[validate-json-schema]: https://github.com/jonasschmidt/ex_json_schema
