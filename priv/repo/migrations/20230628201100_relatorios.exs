defmodule Proj.Repo.Migrations.Relatorios do
  use Ecto.Migration

  def change do
    create table(:relatorios) do
      add(:tipo, :string, null: false)
      add(:data, :date, null: false)
      add :projeto, references(:projetos, on_delete: :delete_all), null: false
    end

  end
end
