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

  def buscar_projeto(nome) do
    DB.one(
      Proj.Projeto
      |> select([projeto], projeto)
      |> where([projeto], projeto.nome == ^nome)
    )
  end

  def buscar_projeto_nomes() do
    projetos = DB.all(
      Proj.Projeto
      |> select([projeto], projeto.nome)
    )
    projetos
  end

  def buscar_tarefa_nomes() do
    tarefas = DB.all(
      Proj.Tarefa
      |> select([tarefa], tarefa.id)
    )
    tarefas
  end

  def buscar_membro_nomes() do
    membros = DB.all(
      Proj.Membro
      |> select([membro], membro.nome)
    )
    membros
  end

  def buscar_habilidade_nomes() do
    habilidades = DB.all(
      Proj.Habilidade
      |> select([habilidade], habilidade.nome)
    )
    habilidades
  end

  def buscar_proj_id(nome) do
    id_projeto = DB.one(
      Proj.Projeto
      |> select([projeto], projeto.id)
      |> where([projeto], projeto.nome == ^nome)
    )
    id_projeto
  end

  def buscar_proj_nome(id) do
    nome_projeto = DB.one(
      Proj.Projeto
      |> select([projeto], projeto.nome)
      |> where([projeto], projeto.id == ^id)
    )
    nome_projeto
  end

  def buscar_membro_id(nome) do
    id_membro = DB.one(
      Proj.Membro
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
    IO.puts("MEMBROS")
    IO.puts("-------------------------")
    Enum.each(membros, fn membro ->

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

  def buscar_all_habilidades do
    habilidades = DB.all(
      Proj.Habilidade
      |> select([habilidade], habilidade)
      |> order_by(asc: :id)
    )
    IO.puts("HABILIDADES")
    IO.puts("-------------------------")
    Enum.each(habilidades, fn habilidade ->
      IO.puts("Id: #{habilidade.id} Nome: #{habilidade.nome}")
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
    IO.puts("PROJETOS")
    IO.puts("-------------------------")
    Enum.each(projetos, fn projeto ->
      membros = projeto.membros
      |> Enum.map(fn membro -> Map.get(membro, :nome) |> String.trim end)
      |> Enum.join(", ")
      responsavel = projeto.responsavel |> Map.get(:nome) |> String.trim |> String.replace("\"", "")
      IO.puts("Nome do Projeto: #{projeto.nome} \nDescricao: #{projeto.descricao} \nData inicial: #{inverter_data(projeto.data_ini)} \nData termino prevista: #{inverter_data(projeto.data_term)} \nStatus: #{projeto.status} \nResponsavel: #{responsavel}\nMembros: #{membros} \n")
      IO.puts("")
    end)
  end

  def buscar_all_tarefas do
    tarefas = DB.all(
      Proj.Tarefa
      |> select([tarefa], tarefa)
      |> order_by(asc: :id)
      |> preload(:membro_respons)
      |> preload(:proj_associado)
    )
    IO.puts("TAREFAS")
    IO.puts("-------------------------")
    Enum.each(tarefas, fn tarefa ->
      responsavel = tarefa.membro_respons |> Map.get(:nome) |> String.trim |> String.replace("\"", "")
      projet = tarefa.proj_associado |> Map.get(:nome) |> String.trim |> String.replace("\"", "")
      IO.puts("Descricao: #{tarefa.descricao} \nData inicial: #{inverter_data(tarefa.data_ini)} \nData termino prevista: #{inverter_data(tarefa.data_term)} \nStatus: #{tarefa.status} \nResponsavel: #{responsavel}\nProjeto: #{projet} \n")
      IO.puts("")
    end)
  end

  def buscar_membros_hab(nome_habil) do
    habilidade = DB.one(
      Proj.Habilidade
      |> select([habilidade], habilidade)
      |> where([habilidade], habilidade.nome == ^nome_habil)
      |> order_by(asc: :id)
      |> preload(:membros)
    )
    IO.puts("MEMBROS COM A HABILIDADE: #{nome_habil}")
    IO.puts("-------------------------")
    membros = habilidade.membros
    |> Enum.map(fn membro -> Map.get(membro, :nome) |> String.trim end)
    |> Enum.join(", ")
    IO.puts("Membros: #{membros} \n")
    IO.puts("")
  end

  def buscar_projetos_membro(nome_membro) do
    membro = DB.one(
      Proj.Membro
      |> select([membro], membro)
      |> where([membro], membro.nome == ^nome_membro)
      |> order_by(asc: :id)
      |> preload(:projetos)
    )
    IO.puts("PROJETOS DO MEMBRO: #{nome_membro}")
    IO.puts("-------------------------")
    projetos = membro.projetos
    |> Enum.map(fn projeto -> Map.get(projeto, :nome) |> String.trim end)
    |> Enum.join(", ")
    IO.puts("Projetos: #{projetos} \n")
    IO.puts("")

  end

  def buscar_membros_projeto(nome_proj) do
    projeto = DB.one(
      Proj.Projeto
      |> select([projeto], projeto)
      |> where([projeto], projeto.nome == ^nome_proj)
      |> order_by(asc: :id)
      |> preload(:membros)
    )
    IO.puts("MEMBROS DO PROJETO: #{nome_proj}")
    IO.puts("-------------------------")
    membros = projeto.membros
    |> Enum.map(fn membro -> Map.get(membro, :nome) |> String.trim end)
    |> Enum.join(", ")
    IO.puts("Membros: #{membros} \n")
    IO.puts("")
  end

  def buscar_documentos_projeto(nome_proj) do
    projeto = DB.one(
      Proj.Projeto
      |> select([projeto], projeto)
      |> where([projeto], projeto.nome == ^nome_proj)
      |> order_by(asc: :id)
      |> preload(:documentos)
    )
    IO.puts("DOCUMENTOS DO PROJETO: #{nome_proj}")
    IO.puts("-------------------------")
    documentos = projeto.documentos
    |> Enum.map(fn documento -> Map.get(documento, :nome) |> String.trim end)
    |> Enum.join(", ")
    IO.puts("Documentos: #{documentos} \n")
    IO.puts("")
  end

  def buscar_relatorios_projeto(nome_proj) do
    projeto = DB.one(
      Proj.Projeto
      |> select([projeto], projeto)
      |> where([projeto], projeto.nome == ^nome_proj)
      |> order_by(asc: :id)
      |> preload(:relatorios)
    )
    IO.puts("DOCUMENTOS DO PROJETO: #{nome_proj}")
    IO.puts("-------------------------")
    relatorios = projeto.relatorios
    |> Enum.map(fn relatorio -> Map.get(relatorio, :tipo) |> String.trim end)
    |> Enum.join(", ")
    IO.puts("Relatorios: #{relatorios} \n")
    IO.puts("")
  end

  def buscar_projetos_status(status) do
    projetos = DB.all(
      Proj.Projeto
      |> select([projeto], projeto)
      |> where([projeto], projeto.status == ^status)
      |> order_by(asc: :id)
      |> preload(:responsavel)
    )
    IO.puts("PROJETOS COM O STATUS: #{status}")
    IO.puts("-------------------------")
    Enum.each(projetos, fn projeto ->
      responsavel = projeto.responsavel |> Map.get(:nome) |> String.trim |> String.replace("\"", "")
      IO.puts("Nome do Projeto: #{projeto.nome} \nData inicial: #{projeto.data_ini} \nResponsavel: #{responsavel}\n")
      IO.puts("")
    end)
  end

  def buscar_taref_conc_proj(nome_proj) do
    proj_id = buscar_proj_id(nome_proj)
    tarefas = DB.all(
      Proj.Tarefa
      |> select([tarefa], tarefa)
      |> where([tarefa], tarefa.status == "concluida")
      |> where([tarefa], tarefa.projeto_associado == ^proj_id)
      |> order_by(asc: :id)
      |> preload(:membro_respons)

    )
    IO.puts("TAREFAS CONCLUIDAS DO PROJETO: #{nome_proj}")
    IO.puts("-------------------------")
    Enum.each(tarefas, fn tarefa ->
      responsavel = tarefa.membro_respons |> Map.get(:nome) |> String.trim |> String.replace("\"", "")
      IO.puts("Descricao: #{tarefa.descricao} \nData inicial: #{tarefa.data_ini} \nData termino prevista: #{tarefa.data_term} \nResponsavel: #{responsavel}\n")
      IO.puts("")
    end)
  end

  def buscar_projetos_atras() do
    data_atual = obter_data_atual()
    projetos = DB.all(
      Proj.Projeto
      |> select([projeto], projeto)
      |> where([projeto], projeto.status == "em andamento")
      |> where([projeto], projeto.data_term < ^data_atual)

      |> order_by(asc: :id)
      |> preload(:responsavel)
    )
    IO.puts("PROJETOS ATRASADOS")
    IO.puts("-------------------------")
    Enum.each(projetos, fn projeto ->
      responsavel = projeto.responsavel |> Map.get(:nome) |> String.trim |> String.replace("\"", "")
      IO.puts("Nome do Projeto: #{projeto.nome} \nData inicial: #{projeto.data_ini} \nData termino previsto: #{projeto.data_term} \nResponsavel: #{responsavel}\n")
      IO.puts("")
    end)
  end

  def buscar_tarefas_proj(nome_proj) do
    proj_id = buscar_proj_id(nome_proj)
    tarefas = DB.all(
      Proj.Tarefa
      |> select([tarefa], tarefa)
      |> where([tarefa], tarefa.projeto_associado == ^proj_id)
      |> order_by(asc: :id)
      |> preload(:membro_respons)

    )
    IO.puts("TAREFAS DO PROJETO: #{nome_proj}")
    IO.puts("-------------------------")
    Enum.each(tarefas, fn tarefa ->
      responsavel = tarefa.membro_respons |> Map.get(:nome) |> String.trim |> String.replace("\"", "")
      IO.puts("Descricao: #{tarefa.descricao} \nData inicial: #{tarefa.data_ini} \nData termino prevista: #{tarefa.data_term} \nStatus: #{tarefa.status} \nResponsavel: #{responsavel}\n")
      IO.puts("")
    end)
  end

  def inserir_projeto(nome, descricao, data_ini, data_term, status, id_responsavel) do
    d_ini = converter_data(data_ini)
    d_term = converter_data(data_term)
    projeto = %Proj.Projeto{nome: nome, descricao: descricao, data_ini: d_ini, data_term: d_term, status: status, id_responsavel: id_responsavel}
    case DB.insert(projeto) do
      {:ok, _} ->
        IO.puts("\nProjeto criado com sucesso\n")
        {:ok, :projeto_criado}

      {:error, _} ->
        IO.puts("\nErro ao criar projeto, tente novamente\n")
        {:error, :erro_projeto}
    end

  end

  def inserir_tarefa(descricao, data_ini, data_term, status, id_responsavel, id_projeto) do
    d_ini = converter_data(data_ini)
    d_term = converter_data(data_term)

    tarefa = %Proj.Tarefa{descricao: descricao, data_ini: d_ini, data_term: d_term, status: status, membro_responsavel: id_responsavel, projeto_associado: id_projeto}
    case DB.insert(tarefa) do
      {:ok, _} ->
        IO.puts("\nTarefa criada com sucesso\n")
        {:ok, :tarefa_criado}

      {:error, _} ->
        IO.puts("\nErro ao criar tarefa, tente novamente\n")
        {:error, :erro_tarefa}
    end
  end

  def inserir_documento(nome, descricao, versao, id_projeto) do
    documento = %Proj.Documento{nome: nome, descricao: descricao, versao: versao, projeto: id_projeto}
    # documento |> DB.insert()
    case DB.insert(documento) do
      {:ok, _} ->
        IO.puts("\nDocumento criado com sucesso\n")
        {:ok, :documento_criado}

      {:error, _} ->
        IO.puts("\nErro ao inserir o documento, tente novamente\n")
        {:error, :erro_documento}
    end
  end

  def inserir_relatorio(tipo, data, id_projeto) do
    cdata = converter_data(data)
    relatorio = %Proj.Relatorio{tipo: tipo, data: cdata, projeto: id_projeto}
    # documento |> DB.insert()
    case DB.insert(relatorio) do
      {:ok, _} ->
        IO.puts("\nRelatorio criado com sucesso\n")
        {:ok, :relatorio_criado}

      {:error, _} ->
        IO.puts("\nErro ao inserir o relatorio, tente novamente\n")
        {:error, :erro_relatorio}
    end
  end

  def associar_hab_membro(nome_habilidade, id_membro) do
    habilidade = buscar_habilidade(nome_habilidade)
    params = %{
      membros: [
        %{id: id_membro}
      ]
    }
    case update_associations(DB, habilidade, params) do
      {:ok, _} ->
        IO.puts("\nHabilidade atribuida com sucesso\n")
        {:ok, :habilidade_assoc}

      {:error, _} ->
        IO.puts("\nErro ao atribuir a habilidade, tente novamente\n")
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
        IO.puts("\nMembero atribuido com sucesso\n")
        {:ok, :membro_assoc}

      {:error, _} ->
        IO.puts("\nErro ao atribuir o membro, tente novamente\n")
        {:error, :erro_membro_assoc}
    end
  end

  def update_projeto_stts(nome_projeto, status) do
    DB.get_by(Proj.Projeto, nome: nome_projeto)
    |> Ecto.Changeset.change(%{status: status})
    |> DB.update()
  end

  def update_projeto_prazo(nome_projeto, prazo) do
    DB.get_by(Proj.Projeto, nome: nome_projeto)
    |> Ecto.Changeset.change(%{data_term: prazo})
    |> DB.update()
  end

  def update_tarefa_prazo(id_tarefa, prazo) do
    DB.get_by(Proj.Tarefa, id: id_tarefa)
    |> Ecto.Changeset.change(%{data_term: prazo})
    |> DB.update()
  end

  def update_tarefa_stts(id_tarefa, status) do
    DB.get_by(Proj.Tarefa, id: id_tarefa)
    |> Ecto.Changeset.change(%{status: status})
    |> DB.update()
  end

  def update_projeto_resp(nome_projeto, nome_respons) do
    id_respons = buscar_membro_id(nome_respons)
    DB.get_by(Proj.Projeto, nome: nome_projeto)
    |> Ecto.Changeset.change(%{id_responsavel: id_respons})
    |> DB.update()
  end

  def update_tarefa_resp(id_tarefa, nome_respons) do
    id_respons = buscar_membro_id(nome_respons)
    DB.get_by(Proj.Tarefa, id: id_tarefa)
    |> Ecto.Changeset.change(%{membro_responsavel: id_respons})
    |> DB.update()
  end

  def main do
    limpar_console()
    IO.puts("GERENCIAMENTO DE PROJETOS")
    IO.puts("-------------------------")
    IO.puts("MENU")
    IO.puts("1- CRIACAO / CADASTROS")
    IO.puts("2- BUSCAS")
    IO.puts("3- EDITAR STATUS DE PROJETOS / TAREFAS")
    IO.puts("4- SAIR")

    choice = IO.gets(" ") |> String.trim

    case choice do
      "1" ->
        limpar_console()
        menu_cadastros()

      "2" ->
        limpar_console()
        menu_buscas()

      "3" ->
        limpar_console()
        menu_update()

      "4" ->
        exit(:normal)
      _ -> IO.puts("Opção invalida. Tente novamente.")
    end

    main()
  end

  @spec menu_cadastros() :: no_return
  defp menu_cadastros() do
    IO.puts("MENU CADASTROS")
    IO.puts("-------------------------")
    IO.puts("1- CRIAR PROJETO")
    IO.puts("2- CRIAR TAREFA")
    IO.puts("3- CADASTRAR MEMBRO")
    IO.puts("4- CADASTRAR HABILIDADE")
    IO.puts("5- ATRIBUIR HABILIDADE A MEMBRO")
    IO.puts("6- ATRIBUIR MEMBRO A PROJETO")
    IO.puts("7- ATRIBUIR DOCUMENTO")
    IO.puts("8- CRIAR RELATORIO")
    IO.puts("9- VOLTAR")
    op1 = IO.gets(" ") |> String.trim

    case op1 do
      "1" ->
        limpar_console()
        IO.puts("CRIAR PROJETO")
        nome = String.downcase(IO.gets("NOME:") |> String.trim)
        descric = String.downcase(IO.gets("DESCRICAO:") |> String.trim)
        data_ini = IO.gets("DATA INICIAL (dd-mm-yyyy): ") |> String.trim
        data_ini = valida_data(data_ini)
        data_term = IO.gets("DATA DO TERMINO PREVISTO (dd-mm-yyyy): ") |> String.trim
        data_term = valida_data(data_term)
        status = String.downcase(IO.gets("STATUS (ex: em andamento, concluido, cancelado): ") |> String.trim)
        status = valida_stts_p(status)
        n_resp = String.downcase(IO.gets("NOME DO RESPONSAVEL: ") |> String.trim)
        n_resp = valida_membro(n_resp)
        respons = buscar_membro_id(n_resp)
        inserir_projeto(nome, descric, data_ini, data_term, status, respons)

      "2" ->
        limpar_console()
        IO.puts("CRIAR TAREFA")
        descric = String.downcase(IO.gets("DESCRICAO:") |> String.trim)
        data_ini = String.downcase(IO.gets("DATA INICIAL (dd-mm-yyyy)") |> String.trim)
        data_term = String.downcase(IO.gets("DATA DO TERMINO PREVISTO (dd-mm-yyyy): ") |> String.trim)
        status = String.downcase(IO.gets("STATUS (em andamento, concluida, pendente): ") |> String.trim)
        status = String.downcase(status)
        status = valida_stts_t(status)

        n_resp = String.downcase(IO.gets("NOME DO RESPONSAVEL: ") |> String.trim)
        n_resp = valida_membro(n_resp)
        respons = buscar_membro_id(n_resp)
        p_ass= String.downcase(IO.gets("NOME DO PROJETO: ") |> String.trim)
        p_ass = valida_projeto(p_ass)
        proj_assoc = buscar_proj_id(p_ass)
        inserir_tarefa(descric, data_ini, data_term, status, respons, proj_assoc)

      "3" ->
        limpar_console()
        IO.puts("CADASTRAR MEMBRO")
        nome = String.downcase(IO.gets("NOME: ") |> String.trim)
        funcao = String.downcase(IO.gets("FUNCAO: ") |> String.trim)
        inserir_membro(nome, funcao)

      "4" ->
        limpar_console()
        IO.puts("CADASTRAR HABILIDADE")
        nome = String.downcase(IO.gets("NOME: ") |> String.trim)
        inserir_habilidade(nome)

      "5" ->
        limpar_console()
        IO.puts("ATRIBUIR HABILIDADE A MEMBRO")
        nome_m = String.downcase(IO.gets("NOME DO MEMBRO: ") |> String.trim)
        nome_m = valida_membro(nome_m)
        id_membro = buscar_membro_id(nome_m)
        nome_h = String.downcase(IO.gets("NOME DA HABILIDADE: ") |> String.trim)
        nome_h = valida_habilidade(nome_h)
        associar_hab_membro(nome_h, id_membro)

      "6" ->
        limpar_console()
        IO.puts("ATRIBUIR MEMBRO A UM PROJETO")
        nome_m = String.downcase(IO.gets("NOME DO MEMBRO: ") |> String.trim)
        nome_m = valida_membro(nome_m)
        nome_proj = String.downcase(IO.gets("NOME DO PROJETO: ") |> String.trim)
        nome_proj = valida_projeto(nome_proj)
        id_proj = buscar_proj_id(nome_proj)
        associar_membro_projeto(nome_m, id_proj)

      "7" ->
        limpar_console()
        IO.puts("ATRIBUIR DOCUMENTO")
        nome = String.downcase(IO.gets("NOME: ") |> String.trim)
        desc = String.downcase(IO.gets("DESCRICAO: ") |> String.trim)
        versao = String.downcase(IO.gets("VERSÃO: ") |> String.trim)
        nome_proj = String.downcase(IO.gets("NOME DO PROJETO: ") |> String.trim)
        nome_proj = valida_projeto(nome_proj)
        id_proj = buscar_proj_id(nome_proj)
        inserir_documento(nome,desc,versao,id_proj)

      "8" ->
        limpar_console()
        IO.puts("CRIAR RELATORIO")
        tipo = String.downcase(IO.gets("TIPO: ") |> String.trim)
        data = String.downcase(IO.gets("DATA: ") |> String.trim)
        data = valida_data(data)
        nome_proj = String.downcase(IO.gets("NOME DO PROJETO: ") |> String.trim)
        nome_proj = valida_projeto(nome_proj)
        id_proj = buscar_proj_id(nome_proj)
        inserir_relatorio(tipo,data,id_proj)

      "9" -> main()

        _ -> IO.puts("Opcao invalida. Tente novamente.")
    end

    menu_cadastros()
  end

  @spec menu_buscas() :: no_return
  defp menu_buscas() do
    IO.puts("MENU BUSCAS")
    IO.puts("-------------------------")
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
    IO.puts("12- BUSCAR TAREFAS DE UM PROJETO")
    IO.puts("13- BUSCAR RELATORIOS DE UM PROJETO")
    IO.puts("14- VOLTAR")
    op1 = IO.gets(" ") |> String.trim

    case op1 do
      "1" ->
        limpar_console()
        buscar_all_projetos()

      "2" ->
        limpar_console()
        buscar_all_membros()

      "3" ->
        limpar_console()
        buscar_all_habilidades()

      "4" ->
        limpar_console()
        buscar_all_tarefas()

      "5" ->
        limpar_console()
        nome = String.downcase(IO.gets("DIGITE O NOME DA HABILIDADE:") |> String.trim)
        nome = valida_habilidade(nome)
        buscar_membros_hab(nome)

      "6" ->
        limpar_console()
        nome = String.downcase(IO.gets("DIGITE O NOME DO MEMBRO:") |> String.trim)
        nome = valida_membro(nome)
        buscar_projetos_membro(nome)

      "7" ->
        limpar_console()
        nome = String.downcase(IO.gets("DIGITE O NOME DO PROJETO:") |> String.trim)
        nome = valida_projeto(nome)
        buscar_membros_projeto(nome)

      "8" ->
        limpar_console()
        nome = String.downcase(IO.gets("DIGITE O NOME DO PROJETO:") |> String.trim)
        nome = valida_projeto(nome)
        buscar_documentos_projeto(nome)

      "9" ->
        limpar_console()
        status = String.downcase(IO.gets("DIGITE O STATUS (ex: em andamento, concluido, cancelado): ") |> String.trim)
        status = valida_stts_p(status)
        buscar_projetos_status(status)

      "10" ->
        limpar_console()
        nome = String.downcase(IO.gets("DIGITE O NOME DO PROJETO:") |> String.trim)
        nome = valida_projeto(nome)
        buscar_taref_conc_proj(nome)

      "11" ->
        limpar_console()
        buscar_projetos_atras()

      "12" ->
        limpar_console()
        nome = String.downcase(IO.gets("DIGITE O NOME DO PROJETO:") |> String.trim)
        nome = valida_projeto(nome)
        buscar_tarefas_proj(nome)

      "13" ->
        limpar_console()
        nome = String.downcase(IO.gets("DIGITE O NOME DO PROJETO:") |> String.trim)
        nome = valida_projeto(nome)
        buscar_relatorios_projeto(nome)

      "14" -> main()

      _ -> IO.puts("Opcao invalida. Tente novamente.")

    end
    menu_buscas()

  end

  @spec menu_update() :: no_return
  defp menu_update() do
    IO.puts("MENU EDITAR PROJETOS / TAREFAS")
    IO.puts("----------------------------------------")
    IO.puts("1- EDITAR STATUS DE UM PROJETO")
    IO.puts("2- EDITAR STATUS DE UMA TAREFA")
    IO.puts("3- EDITAR RESPONSAVEL DE UM PROJETO")
    IO.puts("4- EDITAR RESPONSAVEL DE UMA TAREFA")
    IO.puts("5- PRAZO DE UM PROJETO")
    IO.puts("6- PRAZO DE UMA TAREFA")
    IO.puts("7- VOLTAR")
    op1 = IO.gets(" ") |> String.trim

    case op1 do
      "1" ->
        limpar_console()
        nome_p = IO.gets("DIGITE O NOME DO PROJETO:") |> String.trim
        nome_p = String.downcase(nome_p)
        nome_p = valida_projeto(nome_p)

        status = IO.gets("DIGITE O NOVO STATUS (ex: em andamento, concluido, cancelado):") |> String.trim
        status = String.downcase(status)
        status = valida_stts_p(status)

        update_projeto_stts(nome_p, status)
        IO.puts("\nStatus atualizado com sucesso\n")

      "2" ->
        limpar_console()
        id_tarefa = String.to_integer(IO.gets("DIGITE O NUMERO DA TAREFA:") |> String.trim)
        id_tarefa = valida_tarefa(id_tarefa)

        status = IO.gets("DIGITE O NOVO STATUS (ex: em andamento, concluida, pendente):") |> String.trim
        status = String.downcase(status)
        status = valida_stts_t(status)

        update_tarefa_stts(id_tarefa, status)
        IO.puts("\nStatus atualizado com sucesso\n")


      "3" ->
        limpar_console()
        nome_p = IO.gets("DIGITE O NOME DO PROJETO:") |> String.trim
        nome_p = String.downcase(nome_p)
        nome_p = valida_projeto(nome_p)
        nome_resp = IO.gets("DIGITE O NOME DO NOVO RESPONSAVEL:") |> String.trim
        nome_resp = String.downcase(nome_resp)
        nome_resp = valida_membro(nome_resp)
        update_projeto_resp(nome_p, nome_resp)

        IO.puts("\nResponsavel atualizado com sucesso\n")


      "4" ->
        limpar_console()
        id_tarefa = String.to_integer(IO.gets("DIGITE O NUMERO DA TAREFA:") |> String.trim)
        id_tarefa = valida_tarefa(id_tarefa)

        nome_resp = IO.gets("DIGITE O NOME DO NOVO RESPONSAVEL:") |> String.trim
        nome_resp = String.downcase(nome_resp)
        nome_resp = valida_membro(nome_resp)
        update_tarefa_resp(id_tarefa, nome_resp)

        IO.puts("\nResponsavel atualizado com sucesso\n")

      "5" ->
        limpar_console()
        nome_p = IO.gets("DIGITE O NOME DO PROJETO:") |> String.trim
        nome_p = String.downcase(nome_p)
        nome_p = valida_projeto(nome_p)
        data_term = IO.gets("DATA DO PRAZO(dd-mm-yyyy): ") |> String.trim
        data_term = valida_data(data_term)
        data_term = converter_data(data_term)
        update_projeto_prazo(nome_p, data_term)
        IO.puts("\nPrazo definido com sucesso\n")
      "6" ->
        limpar_console()
        id_tarefa = String.to_integer(IO.gets("DIGITE O NUMERO DA TAREFA:") |> String.trim)
        id_tarefa = valida_tarefa(id_tarefa)
        data_term = IO.gets("DATA DO PRAZO(dd-mm-yyyy): ") |> String.trim
        data_term = valida_data(data_term)
        data_term = converter_data(data_term)
        update_tarefa_prazo(id_tarefa, data_term)
        IO.puts("\nPrazo definido com sucesso\n")
      "7" ->
        limpar_console()
        main()
      _ -> IO.puts("Opcao invalida. Tente novamente.")
    end

    menu_update()
  end

  defp converter_data(string_data) do
    [dia, mes, ano] = String.split(string_data, "-") |> Enum.map(&String.to_integer/1)
    Date.from_erl!({ano, mes, dia})
  end

  def inverter_data(date) do
    "#{date.day}-#{date.month}-#{date.year}"
  end

  @spec obter_data_atual() :: no_return
  def obter_data_atual do
    {ano, mes, dia} = Date.utc_today() |> Date.to_erl
    Date.from_erl!({ano, mes, dia})
  end

  defp valida_stts_p(status) do
    case status do
      "em andamento" ->
        status
      "concluido" ->
        status
      "cancelado" ->
        status
      _ ->
        status = IO.gets("Status invalido. Tente novamente: ") |> String.trim
        valida_stts_p(status)
    end
    status
  end

  defp valida_stts_t(status) do
    case status do
      "em andamento" ->
        status
      "concluida" ->
        status
      "pendente" ->
        status
      _ ->
        status = IO.gets("Status invalido. Tente novamente: ") |> String.trim
        valida_stts_t(status)
    end
    status
  end

  def valida_projeto(projeto) do
    projetos = buscar_projeto_nomes()

    if projeto in projetos do
      projeto
    else
      projeto = IO.gets("Projeto invalido. Tente novamente: ") |> String.trim
      projeto = valida_projeto(projeto)
      projeto
    end
  end

  def valida_membro(membro) do
    membros = buscar_membro_nomes()

    if membro in membros do
      membro
    else
      membro = IO.gets("Membro invalido. Tente novamente: ") |> String.trim
      membro = valida_membro(membro)
      membro
    end
  end

  def valida_tarefa(tarefa) do
    tarefas = buscar_tarefa_nomes()

    if tarefa in tarefas do
      tarefa
    else
      tarefa = String.to_integer(IO.gets("Tarefa invalida. Tente novamente: ") |> String.trim)
      tarefa = valida_tarefa(tarefa)
      tarefa
    end
  end

  def valida_habilidade(habilidade) do
    habilidades = buscar_habilidade_nomes()

    if habilidade in habilidades do
      habilidade
    else
      habilidade = IO.gets("Habilidade invalida. Tente novamente: ") |> String.trim
      habilidade = valida_habilidade(habilidade)
      habilidade
    end
  end

  def valida_data(string) do
    if String.match?(string, ~r/^\d{2}-\d{2}-\d{4}$/) do
      [dia, mes, ano] = String.split(string, "-")
      {parsed_dia, _} = Integer.parse(dia)
      {parsed_mes, _} = Integer.parse(mes)
      {parsed_ano, _} = Integer.parse(ano)

      if parsed_dia >= 1 and parsed_dia <= 31 and
        parsed_mes >= 1 and parsed_mes <= 12 and
        parsed_ano >= 1 do
        string
      else
        string = IO.gets("Tarefa invalida. Tente novamente: ") |> String.trim
        string = valida_data(string)
        string
      end
    else
      string = IO.gets("Tarefa invalida. Tente novamente: ") |> String.trim
      string = valida_data(string)
      string
    end
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
