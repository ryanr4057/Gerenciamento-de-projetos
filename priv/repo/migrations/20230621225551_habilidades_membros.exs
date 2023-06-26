defmodule Proj.Repo.Migrations.HabilidadesMembros do
  use Ecto.Migration

  def change do
    create table(:habilidades_membros, primary_key: false) do
      add :habilidade_id, references(:habilidades, on_delete: :delete_all), null: false
      add :membro_id, references(:membros, on_delete: :delete_all), null: false
    end

    create unique_index(:habilidades_membros, [:habilidade_id, :membro_id])

  end
end
