defmodule Proj.Membro do
  use Ecto.Schema
  use Assoc.Schema, repo: Proj.Repo


  schema "membros" do
    field(:nome, :string)
    field(:funcao, :string)

    has_one(:projeto_respons, Proj.Projeto, foreign_key: :id_responsavel, on_delete: :delete_all, on_replace: :delete)

    has_many(:habilidades_membro, Proj.HabilidadeMembro)
    many_to_many(:habilidades, Proj.Habilidade, join_through: "habilidades_membros")

    has_many(:membro_projetos, Proj.MembroProjeto)
    many_to_many(:projetos, Proj.Projeto, join_through: "membros_projetos")

    has_many(:tarefas, Proj.Tarefa, foreign_key: :membro_responsavel, on_delete: :delete_all, on_replace: :delete)

  end

  def updatable_associations, do: [
    projetos: Proj.Projeto

  ]

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:nome, :funcao])
    |> Ecto.Changeset.validate_required([:nome])
  end

end
