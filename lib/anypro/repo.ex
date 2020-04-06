defmodule Anypro.Repo do
  use Ecto.Repo,
    otp_app: :anypro,
    adapter: Ecto.Adapters.Postgres
end
