defmodule Proj do
  alias Proj.Repo, as: DB
  import Ecto.Query
  import Assoc.Updater



  @moduledoc """
  Documentation for `Proj`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Proj.hello()
      :world

  """

  def inserir_habilidade(nome) do
    habilidade = %Proj.Habilidade{nome: nome}
    habilidade |> DB.insert()
    # IO.puts("\e[2J")
    {:ok, IO.puts("habilidade inserida")}
  end


  def buscar_habilidade(nome) do
    DB.one(
      Proj.Habilidade
      |> select([habilidade], habilidade)
      |> where([habilidade], habilidade.nome == ^nome)
      |> preload(:membros)
    )
  end

  def buscar_all_habilidades do
    DB.all(
      Proj.Habilidade
      |> select([habilidade], {habilidade.nome})
      |> order_by(desc: :inserted_at)
    )
  end

  def inserir_membro(nome, funcao) do
    membro = %Proj.Membro{nome: nome, funcao: funcao}
    membro |> DB.insert()
    :ok
  end

  def buscar_membro(nome) do
    DB.one(
      Proj.Membro
      |> select([membro], membro)
      |> where([membro], membro.nome == ^nome)
      |> preload(:habilidades)
      |> preload(:projeto_respons)
      |> preload(:projetos)
    )
  end

  def buscar_proj(nome) do
    DB.one(
      Proj.Membro
      |> select([projeto], projeto)
      |> where([projeto], projeto.nome == ^nome)
      |> preload(:membros)

    )
  end

  defp buscar_all_membros do
    membros = DB.all(
      Proj.Membro
      |> select([membro], membro)
      |> order_by(asc: :id)
      |> preload(:habilidades)
    )
    Enum.each(membros, fn membro ->
      habilidades = Enum.map(membro.habilidades, &(&1.nome))
      IO.puts("Nome: #{membro.nome}, Funcao: #{membro.funcao}, Habilidades: #{inspect(habilidades)}")
    end)

  end

  def buscar_all_projetos do
    DB.all(
      Proj.Projeto
      |> select([projeto], projeto)
      |> order_by(asc: :id)
      |> preload(:membros)
    )
  end

  def buscar_all_tarefas do
    DB.all(
      Proj.Tarefa
      |> select([tarefa], tarefa)
      |> order_by(asc: :id)
      |> preload(:membro_respons)
      |> preload(:proj_associado)

    )
  end

  def buscar_tarefas_proj(projeto_associado) do
    DB.one(
      Proj.Tarefa
      |> select([tarefa], tarefa)
      |> where([tarefa], tarefa.projeto_associado == ^projeto_associado)
      |> preload(:membro_respons)
      |> preload(:proj_associado)
    )
  end

  def inserir_projeto(nome, descricao, data_ini, data_term, status, id_responsavel) do
    d_ini = converter_data(data_ini)
    d_term = converter_data(data_term)
    projeto = %Proj.Projeto{nome: nome, descricao: descricao, data_ini: d_ini, data_term: d_term, status: status, id_responsavel: id_responsavel}
    projeto |> DB.insert()

    {:ok, IO.puts("projeto criado")}
  end

  def inserir_tarefa(descricao, data_ini, data_term, status, id_responsavel, id_projeto) do
    d_ini = converter_data(data_ini)
    d_term = converter_data(data_term)

    tarefa = %Proj.Tarefa{descricao: descricao, data_ini: d_ini, data_term: d_term, status: status, membro_responsavel: id_responsavel, projeto_associado: id_projeto}
    tarefa |> DB.insert()

    # {:ok, IO.puts("tarefa criada")}
  end

  def inserir_documento(nome, descricao, versao, id_projeto) do
    documento = %Proj.Documento{nome: nome, descricao: descricao, versao: versao, projeto_referente: id_projeto}
    documento |> DB.insert()

    {:ok, IO.puts("documento criado")}
  end

  # def ins_projeto(nome, descricao, data_ini, data_term, status, id_responsavel) do
  # %Projeto{}
  # |> Projeto.changeset(params)
  # |> Repo.insert
  # |> update_associations(params)
  # end

  def associar_hab_membro(nome_habilidade, id_membro) do
    habilidade = buscar_habilidade(nome_habilidade)
    params = %{
      membros: [
        %{id: id_membro}
      ]
    }
    update_associations(DB, habilidade, params)
  end

  def associar_membro_projeto(nome_membro, id_projeto) do
    membro = buscar_membro(nome_membro)
    params = %{
      projetos: [
        %{id: id_projeto}
      ]
    }
    update_associations(DB,membro,params)
    :ok
  end

  def loop do

    IO.puts("Opcoes:")
    IO.puts("1. inserir habilidade")
    IO.puts("2. Buscar usuario")
    IO.puts("0. Sair")

    choice = IO.gets("Escolha uma opcao: ") |> String.trim

    case choice do
      "1" -> nome = IO.gets("digite o nome da habilidade: ") |> String.trim
        inserir_habilidade(nome)
      "2" -> buscar_all_membros()
      "0" -> exit(:normal)
      _ -> IO.puts("Opção invalida. Tente novamente.")
    end

    loop()
  end

  defp converter_data(string_data) do
    [dia, mes, ano] = String.split(string_data, "-") |> Enum.map(&String.to_integer/1)
    Date.from_erl!({ano, mes, dia})
  end
  # def atr_hab_membro(membro, habilidade) do
  #   membro
  #   |> membro_changeset = Ecto.Changeset.change(membro)
  #   |> membro_hab = Ecto.Changeset.put_assoc(membro_changeset, :habilidades, [habilidade])
  #   |> Proj.Repo.update!(membro_hab)
  # end

  # def atr_hab_membro(membro, habilidade) do
  #   membro_with_habilidades =
  #     membros
  #     |> Repo.preload(:habilidades)
  #     |> Repo.get!(membro.id)

  #   habilidade_assoc = %{habilidades: [habilidade]}
  #   changeset = Ecto.Changeset.change(MyApp.Membro, membro_with_habilidades) |> Ecto.Changeset.put_assoc(habilidade_assoc)

  #   Repo.update!(changeset)
  # end


  # def atr_hab_membro(membro, habilidade) do
  #   changeset = Ecto.Changeset.change(membro)
  #   |> Proj.Repo.preload(:habilidades)
  #   |> Ecto.Changeset.put_assoc(:habilidades, [habilidade])

  #   case Proj.Repo.update(changeset) do
  #     {:ok, updated_membro} ->
  #       {:ok, updated_membro}
  #     {:error, changeset} ->
  #       {:error, changeset.errors}
  #   end
  # end


  # def add_hab_membro(habilidade, membro) do
  #   unless List.member?(habilidade.membros, membro) do
  #     updated_habilidade = %Proj.Habilidade{habilidade | membros: habilidade.membros ++ [membro]}
  #     {:ok, Proj.Repo.update(updated_habilidade)}
  #   else
  #     {:error, "Role already assigned to user"}
  #   end
  # end



  def hello do
    :world
  end
end
