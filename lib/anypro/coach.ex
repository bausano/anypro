defmodule Anypro.Coach do
  use Ecto.Schema
  import Ecto.Changeset

  # @required_fields ~w(email name)a

  schema "coaches" do
    field :bio, :string
    field :slug, :string
    field :email, :string
    field :name, :string
    field :pga_qualified, :boolean, default: false
    field :phone, :string
    field :pricing, :string
    field :profile_picture, :string

    timestamps()
  end

  @doc false
  def changeset(coach, attrs) do
    coach
    |> cast(attrs, [:name, :email, :phone, :bio, :pricing, :pga_qualified, :profile_picture])
    |> validate_required([:name, :email, :phone, :bio, :pricing, :pga_qualified, :profile_picture])
    |> unique_constraint(:email)
    |> unique_constraint(:slug)
  end

  # Creates a slug from provided coach name.
  # Source from https://hashrocket.com/blog/posts/titled-url-slugs-in-phoenix
  def slugified_name(name) do
    name
    |> String.downcase
    |> String.replace(~r/[^a-z0-9\s-]/, "")
    |> String.replace(~r/(\s|-)+/, "-")
  end
end
