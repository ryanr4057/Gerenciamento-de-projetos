defmodule Proj.Repo.Migrations.Documentos do
  use Ecto.Migration

  def change do
    create table(:documentos) do
      add(:nome, :string, null: false)
      add(:descricao, :string, null: false)
      add(:versao, :string, null: false)
      add :projeto, references(:projetos, on_delete: :delete_all), null: false
      timestamps()
    end
  end

end
