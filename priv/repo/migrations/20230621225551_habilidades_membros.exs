defmodule Proj.Repo.Migrations.HabilidadesMembros do
  use Ecto.Migration

  def change do
    create table(:habilidades_membros, primary_key: false) do
      add :habilidade_id, references(:habilidades, on_delete: :delete_all), null: false, primary_key: true
      add :membro_id, references(:membros, on_delete: :delete_all), null: false,primary_key: true
    end
  end
end
