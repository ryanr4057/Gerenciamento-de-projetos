defmodule Proj do
  alias Proj.Repo, as: DB
  import Ecto.Query
  import Assoc.Updater

  @dialyzer {:nowarn_function, associar_hab_membro: 2}
  @dialyzer {:nowarn_function, associar_membro_projeto: 2}

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
    # habilidade |> DB.insert()
    # IO.puts("\e[2J")
    case DB.insert(habilidade) do
      {:ok, _} ->
        IO.puts("Habilidade cadastrada com sucesso")
        {:ok, :habilidade_criado}

      {:error, _} ->
        IO.puts("Erro ao cadastrar habilidade, tente novamente")
        {:error, :erro_habilidade}
    end



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
    # membro |> DB.insert()

    case DB.insert(membro) do
      {:ok, _} ->
        IO.puts("Membro cadastrado com sucesso")
        {:ok, :membro_criado}

      {:error, _} ->
        IO.puts("Erro ao cadastrar membro, tente novamente")
        {:error, :erro_membro}
    end
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

  defp buscar_proj_id(nome) do
    id_projeto = DB.one(
      Proj.Projeto
      |> select([projeto], projeto.id)
      |> where([projeto], projeto.nome == ^nome)
    )
    id_projeto
  end

  defp buscar_membro_id(nome) do
    id_membro = DB.one(
      Proj.Projeto
      |> select([membro], membro.id)
      |> where([membro], membro.nome == ^nome)
    )
    id_membro
  end

  def buscar_all_membros do
    membros = DB.all(
      Proj.Membro
      |> select([membro], membro)
      |> order_by(asc: :id)
      |> preload(:habilidades)
      |> preload(:projetos)

    )
    Enum.each(membros, fn membro ->
      # habilidades = Enum.map(membro.habilidades, &(&1.nome))

      habilidades = membro.habilidades
      |> Enum.map(fn habilidade -> Map.get(habilidade, :nome) |> String.trim end)
      |> Enum.join(", ")

      projetos = membro.projetos
      |> Enum.map(fn projeto -> Map.get(projeto, :nome) |> String.trim end)
      |> Enum.join(", ")

      IO.puts("Nome: #{membro.nome} \nFuncao: #{membro.funcao} \nHabilidades: #{habilidades} \nProjetos: #{projetos} \n")
      IO.puts("")
    end)

  end

  def buscar_all_projetos do
    projetos = DB.all(
      Proj.Projeto
      |> select([projeto], projeto)
      |> order_by(asc: :id)
      |> preload(:membros)
      |> preload(:documentos)
      |> preload(:responsavel)
    )
    Enum.each(projetos, fn projeto ->
      membros = projeto.membros
      |> Enum.map(fn membro -> Map.get(membro, :nome) |> String.trim end)
      |> Enum.join(", ")
      responsavel = projeto.responsavel |> Map.get(:nome) |> String.trim |> String.replace("\"", "")
      IO.puts("Nome do Projeto: #{projeto.nome} \nDescricao: #{projeto.descricao} \nData inicial: #{projeto.data_ini} \nData termino prevista: #{projeto.data_term} \nStatus: #{projeto.status} \nResponsavel: #{responsavel}\nMembros: #{membros} \n")
      IO.puts("")
    end)
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
    # projeto |> DB.insert()


    case DB.insert(projeto) do
      {:ok, _} ->
        IO.puts("Projeto criado com sucesso")
        {:ok, :projeto_criado}

      {:error, _} ->
        IO.puts("Erro ao criar projeto, tente novamente")
        {:error, :erro_projeto}
    end

  end

  def inserir_tarefa(descricao, data_ini, data_term, status, id_responsavel, id_projeto) do
    d_ini = converter_data(data_ini)
    d_term = converter_data(data_term)

    tarefa = %Proj.Tarefa{descricao: descricao, data_ini: d_ini, data_term: d_term, status: status, membro_responsavel: id_responsavel, projeto_associado: id_projeto}
    # tarefa |> DB.insert()

    case DB.insert(tarefa) do
      {:ok, _} ->
        IO.puts("Tarefa criada com sucesso")
        {:ok, :tarefa_criado}

      {:error, _} ->
        IO.puts("Erro ao criar tarefa, tente novamente")
        {:error, :erro_tarefa}
    end

  end

  def inserir_documento(nome, descricao, versao, id_projeto) do
    documento = %Proj.Documento{nome: nome, descricao: descricao, versao: versao, projeto: id_projeto}
    # documento |> DB.insert()
    case DB.insert(documento) do
      {:ok, _} ->
        IO.puts("Documento criado com sucesso")
        {:ok, :documento_criado}

      {:error, _} ->
        IO.puts("Erro ao inserir o documento, tente novamente")
        {:error, :erro_documento}
    end

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

    case update_associations(DB, habilidade, params) do
      {:ok, _} ->
        IO.puts("Habilidade atribuida com sucesso")
        {:ok, :habilidade_assoc}

      {:error, _} ->
        IO.puts("Erro ao atribuir a habilidade, tente novamente")
        {:error, :erro_habilidade_assoc}
    end

  end


  def associar_membro_projeto(nome_membro, id_projeto) do
    membro = buscar_membro(nome_membro)
    params = %{
      projetos: [ %{id: id_projeto}]
    }

    case update_associations(DB,membro,params) do
      {:ok, _} ->
        IO.puts("Membero atribuido com sucesso")
        {:ok, :membro_assoc}

      {:error, _} ->
        IO.puts("Erro ao atribuir o membro, tente novamente")
        {:error, :erro_membro_assoc}
    end

  end

  def main do

    IO.puts("GERENCIAMENTO DE PROJETOS")
    IO.puts("-------------------------")
    IO.puts("MENU")
    IO.puts("'1- CRIACAO / CADASTROS")
    IO.puts("'2- BUSCAS")
    IO.puts("'3- EDITAR STATUS DE PROJETOS / TAREFAS")
    IO.puts("'4- SAIR")

    choice = IO.gets(" ") |> String.trim

    case choice do
      "1" -> menu_cadastros()
      "2" -> menu_buscas()
      "0" -> exit(:normal)
      _ -> IO.puts("Opção invalida. Tente novamente.")
    end

    main()
  end

  @spec menu_cadastros() :: no_return
  defp menu_cadastros() do
    IO.puts("CADASTROS")
    IO.puts("-------------------------")
    IO.puts("MENU")
    IO.puts("1- CRIAR PROJETO")
    IO.puts("2- CRIAR TAREFA")
    IO.puts("3- CADASTRAR MEMBRO")
    IO.puts("4- CADASTRAR HABILIDADE")
    IO.puts("5- ATRIBUIR HABILIDADE A MEMBRO")
    IO.puts("6- ATRIBUIR MEMBRO A PROJETO")
    IO.puts("7- ATRIBUIR DOCUMENTO")
    IO.puts("8- CRIAR RELATORIO")
    IO.puts("9- SAIR")
    op1 = IO.gets(" ") |> String.trim

    case op1 do
      "1" ->
        IO.puts("CRIAR PROJETO")
        nome = IO.gets("NOME:") |> String.trim
        descric = IO.gets("DESCRICAO:") |> String.trim
        data_ini = IO.gets("DATA INICIAL: (dd-mm-yyyy)") |> String.trim
        data_term = IO.gets("DATA DO TERMINO PREVISTO: (dd-mm-yyyy)") |> String.trim
        status = IO.gets("STATUS: (em andamento, concluido, cancelado)") |> String.trim
        n_resp = IO.gets("NOME DO RESPONSAVEL: ") |> String.trim
        respons = buscar_proj_id(n_resp)
        inserir_projeto(nome, descric, data_ini, data_term, status, respons)

      "2" ->
        IO.puts("CRIAR TAREFA")
        descric = IO.gets("DESCRIÇÃO:") |> String.trim
        data_ini = IO.gets("DATA INICIAL: (dd-mm-yyyy)") |> String.trim
        data_term = IO.gets("DATA DO TERMINO PREVISTO: (dd-mm-yyyy)") |> String.trim
        status = IO.gets("STATUS: (em andamento, concluida, pendente)") |> String.trim
        n_resp = IO.gets("NOME DO RESPONSAVEL: ") |> String.trim
        respons = buscar_membro_id(n_resp)
        p_ass= IO.gets("NOME DO PROJETO: ") |> String.trim
        proj_assoc = buscar_proj_id(p_ass)
        inserir_tarefa(descric, data_ini, data_term, status, respons, proj_assoc)

      "3" ->
        IO.puts("CADASTRAR MEMBRO")
        nome = IO.gets("NOME: ") |> String.trim
        funcao = IO.gets("FUNÇÃO: ") |> String.trim
        inserir_membro(nome, funcao)

      "4" ->
        IO.puts("CADASTRAR HABILIDADE")
        nome = IO.gets("NOME: ") |> String.trim
        inserir_habilidade(nome)

      "5" ->
        IO.puts("ATRIBUIR HABILIDADE A MEMBRO")
        nome_m = IO.gets("NOME DO MEMBRO: ") |> String.trim
        id_membro = buscar_membro_id(nome_m)
        nome_h = IO.gets("NOME DA HABILIDADE: ") |> String.trim
        associar_hab_membro(nome_h, id_membro)

        "6" ->
          IO.puts("ATRIBUIR MEMBRO A UM PROJETO")
          nome_m = IO.gets("NOME DO MEMBRO: ") |> String.trim
          nome_proj = IO.gets("NOME DO PROJETO: ") |> String.trim
          id_proj = buscar_proj_id(nome_proj)
          associar_membro_projeto(nome_m, id_proj)

        "7" ->
          IO.puts("ATRIBUIR DOCUMENTO")
          nome = IO.gets("NOME: ") |> String.trim
          desc = IO.gets("DESCRIÇÃO: ") |> String.trim
          versao = IO.gets("VERSÃO: ") |> String.trim
          nome_proj = IO.gets("NOME DO PROJETO: ") |> String.trim
          id_proj = buscar_proj_id(nome_proj)
          inserir_documento(nome,desc,versao,id_proj)

        "9" -> main()
    end

    menu_cadastros()
  end

  @spec menu_buscas() :: no_return
  defp menu_buscas() do
    IO.puts("BUSCAS")
    IO.puts("-------------------------")
    IO.puts("MENU")
    IO.puts("1- BUSCAR TODOS OS PROJETOS")
    IO.puts("2- BUSCAR TODOS OS MEMBROS")
    IO.puts("3- BUSCAR TODAS AS HABILIDADES")
    IO.puts("4- BUSCAR TODAS AS TAREFAS")
    IO.puts("5- BUSCAR MEMBROS COM UMA HABILIDADE")
    IO.puts("6- BUSCAR PROJETOS DE UM MEMBRO")
    IO.puts("7- BUSCAR MEMBROS DE UM PROJETO")
    IO.puts("8- BUSCAR DOCUMENTOS DE UM PROJETO")
    IO.puts("9- BUSCAR PROJETOS POR STATUS")
    IO.puts("10- BUSCAR TAREFAS CONCLUIDAS DE UM PROJETO")
    IO.puts("11- BUSCAR PROJETOS ATRASADOS")
    IO.puts("12- VOLTAR")
    op1 = IO.gets(" ") |> String.trim

    case op1 do
      "1" -> buscar_all_projetos()
    end

  end

  defp converter_data(string_data) do
    [dia, mes, ano] = String.split(string_data, "-") |> Enum.map(&String.to_integer/1)
    Date.from_erl!({ano, mes, dia})
  end

  def limpar_console do
    for _ <- 1..50 do
      IO.puts("")
    end
  end


  def hello do
    :world
  end
end
