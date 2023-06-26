defmodule Proj.Repo.Migrations.Habilidades do
  use Ecto.Migration

  def change do
    create table(:habilidades) do
      add(:nome, :string), null: false

    end
  end
end
