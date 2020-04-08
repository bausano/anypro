# Anypro

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

## Running in docker
We're using [this guide][docker-with-phoenix] to set up a testing environment in
which our Phoenix app talks to Docker.

Use `docker-compose up --abort-on-container-exit` to create the container. Tests
can be run in the container with `docker-compose run anypro mix test`.

<!-- Invisible List of References -->
[docker-with-phoenix]: https://github.com/fireproofsocks/phoenix-docker-compose
