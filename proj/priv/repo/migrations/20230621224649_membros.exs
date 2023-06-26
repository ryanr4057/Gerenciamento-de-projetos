defmodule Proj.Repo.Migrations.Membros do
  use Ecto.Migration

  def change do
    create table(:membros) do
      add(:nome, :string, null: false)
      add(:funcao, :string, null: false)
    end
  end
end
