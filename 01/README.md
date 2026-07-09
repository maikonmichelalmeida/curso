# 01 - SystemVerilog RTL: mismatch, latch e FSM

Este lab transforma o primeiro bloco util do curso em um estudo comparativo.

Ele nao e apenas uma copia do lab da Synopsys. A ideia aqui e:

- manter exemplos ruins e corretos lado a lado;
- rodar simulacao RTL;
- rodar sintese;
- comparar com simulacao gate-level quando a sintese gerar netlist;
- ler comentarios no codigo e no Tcl;
- seguir o roteiro cronologico em `docs/guia_lab.md`.

## Exemplos

```text
ERRO 01 - sensitivity list incompleta
ERRO 02 - latch nao intencional
ERRO 03 - FSM sem estrutura robusta
```

Cada exemplo tem pelo menos duas variantes:

```text
bad   codigo propositalmente perigoso
good  codigo corrigido
```

## Comece por aqui

No servidor:

```bash
cd ~/curso/01
make help
make doctor
make sim EX=01 CASE=bad
make sim EX=01 CASE=good
```

Depois siga:

```text
docs/guia_lab.md
```
