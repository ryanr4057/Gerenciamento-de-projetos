defmodule Proj.MembroProjeto do
  use Ecto.Schema
  use Assoc.Schema, repo: Proj.Repo

  @primary_key false
  schema "membros_projetos" do
    belongs_to :membro, Proj.Membro, type: :integer, references: :id, primary_key: true
    belongs_to :projeto, Proj.Projeto, type: :integer, references: :id, primary_key: true
  end

  def updatable_associations, do: [
    membro: Proj.Membro,
    projeto: Proj.Projeto
  ]

  def changeset(membro_projeto, attrs) do
    membro_projeto
    |> Ecto.Changeset.cast(attrs, [:membro_id, :projeto_id])
    |> Ecto.Changeset.validate_required([:membro_id, :projeto_id])
  end

  end
