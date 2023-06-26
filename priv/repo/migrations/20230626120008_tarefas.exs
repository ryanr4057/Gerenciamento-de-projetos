defmodule Proj.Repo.Migrations.Tarefas do
  use Ecto.Migration

  def change do
    create table(:tarefas) do
      add(:descricao, :string, null: false)
      add(:data_ini, :date, null: false)
      add(:data_term, :date, null: false)
      add(:status, :string, null: false)
      add :membro_responsavel, references(:membros, on_delete: :delete_all), null: false
      add :projeto_associado, references(:projetos, on_delete: :delete_all), null: false
    end
  end
end
