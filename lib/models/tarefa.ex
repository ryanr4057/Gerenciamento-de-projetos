defmodule Proj.Tarefa do
  use Ecto.Schema
  # use Assoc.Schema, repo: Proj.Repo

  schema "tarefas" do
    field(:descricao, :string)
    field(:data_ini, :date)
    field(:data_term, :date)
    field(:status, :string)

    belongs_to(:membro_respons, Proj.Membro, foreign_key: :membro_responsavel, on_replace: :update)
    belongs_to(:proj_associado, Proj.Projeto, foreign_key: :projeto_associado, on_replace: :update)
  end

  def updatable_associations, do: [
    membro_respons: Proj.Membro,
    proj_associado: Proj.Projeto
  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:descricao, :data_ini, :data_term, :status])
    |> Ecto.Changeset.validate_required([:status])
  end
end
