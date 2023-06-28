defmodule Proj.Relatorio do
  use Ecto.Schema
  use Assoc.Schema, repo: Proj.Repo

  schema "relatorios" do
    field(:tipo, :string)
    field(:data, :date)

    belongs_to(:projeto_referente, Proj.Projeto, foreign_key: :projeto, on_replace: :update)
  end

  def updatable_associations, do: [
    projeto_referente: Proj.Projeto
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:tipo])
    |> Ecto.Changeset.validate_required([:tipo])
  end
end
