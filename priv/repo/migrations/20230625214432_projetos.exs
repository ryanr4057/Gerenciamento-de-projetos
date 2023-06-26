defmodule Proj.Repo.Migrations.Projetos do
  use Ecto.Migration

  def change do
    create table(:projetos) do
      add(:nome, :string, null: false)
      add(:descricao, :string, null: false)
      add(:data_ini, :date, null: false)
      add(:data_term, :date, null: false)
      add(:status, :string, null: false)
      add :id_responsavel, references(:membros, on_delete: :delete_all), null: false
    end
  end
end
