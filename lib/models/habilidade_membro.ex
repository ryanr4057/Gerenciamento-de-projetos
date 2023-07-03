defmodule Proj.HabilidadeMembro do
  use Ecto.Schema
  use Assoc.Schema, repo: Proj.Repo

  @primary_key false
  schema "habilidades_membros" do
    belongs_to :habilidade, Proj.Habilidade, type: :integer, references: :id, primary_key: true
    belongs_to :membro, Proj.Membro, type: :integer, references: :id, primary_key: true
  end

  def updatable_associations, do: [
    habilidade: Proj.Habilidade,
    membro: Proj.Membro
  ]

  def changeset(habilidade_membro, attrs) do
    habilidade_membro
    |> Ecto.Changeset.cast(attrs, [:habilidade_id, :membro_id])
    |> Ecto.Changeset.validate_required([:habilidade_id, :membro_id])
  end

  end
