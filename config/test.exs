use Mix.Config

# Configure your database
config :anypro, Anypro.Repo,
  username: "postgres",
  password: "",
  database: "anypro_test",
  hostname: "anypro-postgres",
  pool: Ecto.Adapters.SQL.Sandbox

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :anypro, AnyproWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn
