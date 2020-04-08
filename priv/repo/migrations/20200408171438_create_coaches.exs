defmodule Anypro.Repo.Migrations.CreateCoaches do
  use Ecto.Migration

  def change do
    create table(:coaches) do
      add :name, :string
      add :slug, :string
      add :email, :string
      add :phone, :string
      add :bio, :string
      add :pricing, :string
      add :pga_qualified, :boolean, default: false, null: false
      add :profile_picture, :string

      timestamps()
    end

    create unique_index(:coaches, [:email, :slug])
  end
end
