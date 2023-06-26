defmodule Proj.Documento do
  use Ecto.Schema
  use Assoc.Schema, repo: Proj.Repo

  schema "documentos" do
    field(:nome, :string)
    field(:descricao, :string)
    field(:versao, :string)

    belongs_to(:projeto_referente, Proj.Projeto, foreign_key: :projeto, on_replace: :update)
    timestamps()
  end

  def updatable_associations, do: [
    projeto_referente: Proj.Projeto
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:nome])
    |> Ecto.Changeset.validate_required([:nome])
  end
end
