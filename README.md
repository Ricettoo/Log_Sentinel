# Log Sentinel

Analisador de logs de rede escrito em **Elixir**, usando o **paradigma funcional**.
Trabalho "Explorando Paradigmas de Programação", UNESPAR, 2026.

## O que faz

Lê um arquivo de log de equipamentos de rede e:

1. conta os eventos por nível (ERROR, WARN, INFO);
2. classifica cada linha por gravidade (CRITICO, ATENCAO, NORMAL, DESCONHECIDO);
3. gera alertas para IPs com 3 ou mais erros.

## Formato do log

Uma linha por evento:

```
DATA HORA NIVEL IP MENSAGEM
2026-11-25 10:00:05 ERROR 10.0.0.2 link down eth0
```

Linhas fora do formato não travam o programa: são classificadas como `DESCONHECIDO`.

## Como executar

1. Instale o Elixir: https://elixir-lang.org/install.html
   - Ubuntu/Debian: `sudo apt install elixir`
   - Windows: instalador disponível no mesmo site
2. Confira a instalação: `elixir --version`
3. Na pasta do projeto, rode:

```bash
elixir log_sentinel.exs            # analisa o rede.log de exemplo
elixir log_sentinel.exs outro.log  # analisa outro arquivo
```

## Exemplo de saída

```
=== LOG SENTINEL ===
Erros:  4
Avisos: 2
Infos:  2

Classificação de cada linha:
[NORMAL] 2026-11-25 10:00:01 INFO 10.0.0.1 ping ok
[CRITICO] 2026-11-25 10:00:05 ERROR 10.0.0.2 link down eth0
...
[DESCONHECIDO] linha quebrada sem formato
...

Alertas (IPs com 3 ou mais erros):
ALERTA: 10.0.0.2 teve 3 erros
```

## Conceitos do paradigma funcional usados

| Conceito | Onde está no código |
| --- | --- |
| Funções puras | `campo`, `nivel`, `ip`, `gravidade`, `contar`, `alertas`, `relatorio` |
| Efeitos isolados nas pontas | `ler` (arquivo) e `imprimir` (tela) |
| Imutabilidade | Nenhum valor é alterado; cada função devolve um valor novo |
| Recursão | `contar`, com caso base (lista vazia) e caso recursivo |
| Pattern matching | `gravidade` (4 cláusulas), `contar` (`[]` e `[linha \| resto]`), leitura dos argumentos |
| Funções de alta ordem | `Enum.filter`, `Enum.map` e `Enum.each` recebendo funções |
| Composição de funções | Operador `\|>` e `nivel`/`ip` construídas a partir de `campo` |
| Expressões | `if` e `case` devolvem valores (`ponto = if ...`) |
| Transformação de dados | `alertas`: linhas → erros → IPs → contagem → alertas |

## Arquivos

| Arquivo | Conteúdo |
| --- | --- |
| `log_sentinel.exs` | Aplicação |
| `rede.log` | Log de exemplo |
