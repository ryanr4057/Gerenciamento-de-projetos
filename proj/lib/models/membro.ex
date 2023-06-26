defmodule Proj.Membro do
  use Ecto.Schema
  # use Assoc.Schema, repo: Proj.Repo


  schema "membros" do
    field(:nome, :string)
    field(:funcao, :string)

    has_one(:projeto_respons, Proj.Projeto, foreign_key: :id_responsavel, on_delete: :delete_all, on_replace: :delete)
    many_to_many(:habilidades, Proj.Habilidade, join_through: "habilidades_membros", on_replace: :delete)

    many_to_many(:projetos, Proj.Projeto, join_through: "membros_projetos", on_replace: :delete)

  end

  def changeset(struct, params \\ %{}) do
    struct
    |> Ecto.Changeset.cast(params, [:nome, :funcao])
    |> Ecto.Changeset.validate_required([:nome])
    |> Ecto.Changeset.validate_required([:funcao])
  end

end
