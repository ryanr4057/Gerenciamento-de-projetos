defmodule Proj.Repo.Migrations.MembrosProjetos do
  use Ecto.Migration

  def change do
    create table(:membros_projetos, primary_key: false) do
      add :membro_id, references(:membros, on_delete: :delete_all), null: false, primary_key: true
      add :projeto_id, references(:projetos, on_delete: :delete_all), null: false, primary_key: true
    end
  end
end
