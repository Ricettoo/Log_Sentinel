# Log Sentinel, analisador de logs de rede
#
# Rodar:  elixir log_sentinel.exs

# Formato de cada linha do log:
#   DATA HORA NIVEL IP MENSAGEM
#   2026-11-25 10:00:05 ERROR 10.0.0.2 link down eth0

defmodule LogSentinel do
  
  # PARTE 1 - FUNÇÕES PURAS
  # Mesma entrada > sempre a mesma saída, Não leem arquivo nem imprimem nada, Só recebem valores e devolvem valores novos

  # Pega a palavra de uma posição da linha (0 = data, 1 = hora, 2 = nível, 3 = IP)
  def campo(linha, posicao) do
    linha
    |> String.split()
    |> Enum.at(posicao)
  end

  # Composição: funções pequenas construídas a partir de outra
  def nivel(linha), do: campo(linha, 2)
  def ip(linha),    do: campo(linha, 3)

  # PATTERN MATCHING: uma versão da função para cada caso
  def gravidade("ERROR"), do: "CRITICO"
  def gravidade("WARN"),  do: "ATENCAO"
  def gravidade("INFO"),  do: "NORMAL"
  def gravidade(_),       do: "DESCONHECIDO"

  # RECURSÃO: conta quantas linhas têm um nível, sem laço e sem contador
  #   caso base:      lista vazia -> 0
  #   caso recursivo: (1 ou 0 da primeira linha) + contagem do resto
  
  def contar([], _nivel_procurado), do: 0

  def contar([linha | resto], nivel_procurado) do
    ponto = if nivel(linha) == nivel_procurado, do: 1, else: 0
    ponto + contar(resto, nivel_procurado)
  end

  # FUNÇÕES DE ALTA ORDEM + TRANSFORMAÇÃO DE DADOS:
  # IPs que tiveram "limite" ou mais erros
  def alertas(linhas, limite) do
    linhas
    |> Enum.filter(fn linha -> nivel(linha) == "ERROR" end)  # só os erros
    |> Enum.map(fn linha -> ip(linha) end)                    # vira lista de IPs
    |> Enum.frequencies()                                     # conta cada IP
    |> Enum.filter(fn {_ip, qtd} -> qtd >= limite end)        # passou do limite?
  end

  # Junta todos os resultados num único valor (um mapa)
  def relatorio(linhas) do
    %{
      erros:  contar(linhas, "ERROR"),
      avisos: contar(linhas, "WARN"),
      infos:  contar(linhas, "INFO"),
      classificadas: Enum.map(linhas, fn linha -> {linha |> nivel() |> gravidade(), linha} end),
      alertas: alertas(linhas, 3)
    }
  end

  # ============================================================
  # PARTE 2 - FUNÇÕES COM EFEITO (mexem com o mundo de fora)
  # Ficam nas pontas: uma lê o arquivo, a outra imprime na tela.
  # ============================================================

  def ler(arquivo) do
    File.read!(arquivo)
    |> String.split("\n", trim: true)
  end

  def imprimir(r) do
    IO.puts("=== LOG SENTINEL ===")
    IO.puts("Erros:  #{r.erros}")
    IO.puts("Avisos: #{r.avisos}")
    IO.puts("Infos:  #{r.infos}")

    IO.puts("\nClassificação de cada linha:")
    Enum.each(r.classificadas, fn {classe, linha} -> IO.puts("[#{classe}] #{linha}") end)

    IO.puts("\nAlertas (IPs com 3 ou mais erros):")

    case r.alertas do
      []    -> IO.puts("Nenhum alerta.")
      lista -> Enum.each(lista, fn {ip, qtd} -> IO.puts("ALERTA: #{ip} teve #{qtd} erros") end)
    end
  end
end

# ============================================================
# PROGRAMA PRINCIPAL
# ler (efeito) -> relatorio (puro) -> imprimir (efeito)
# ============================================================

arquivo =
  case System.argv() do
    [nome | _] -> nome        # passou um arquivo no terminal
    []         -> "rede.log"  # não passou nada: usa o padrão
  end

arquivo
|> LogSentinel.ler()
|> LogSentinel.relatorio()
|> LogSentinel.imprimir()
