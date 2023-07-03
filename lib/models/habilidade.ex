defmodule Proj.Habilidade do
  use Ecto.Schema
  use Assoc.Schema, repo: Proj.Repo

  schema "habilidades" do
    field(:nome, :string)

    has_many(:habilidades_membro, Proj.HabilidadeMembro)
    many_to_many(:membros, Proj.Membro, join_through: "habilidades_membros")
  end

  def updatable_associations, do: [
    membros: Proj.Membro
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:nome])
    |> Ecto.Changeset.validate_required([:nome])
  end

end
