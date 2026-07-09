# Mapa da estrutura do Lab 01

Este arquivo resume o papel de cada item.

| Caminho | Papel |
| --- | --- |
| `Makefile` | Comando humano curto. Delega para as ferramentas. |
| `rtl/lab01_top.sv` | Design sintetizavel. |
| `verif/top_tb.sv` | Testbench de simulacao RTL. |
| `verif/filelist.f` | Arquivos usados pelo VCS. |
| `verif/filelist_rtl.f` | Arquivos usados pelo DC_NXT. |
| `constraints/constraints.sdc` | Contexto de timing do bloco. |
| `tools/vcs/scripts/Makefile` | Receita de compilacao e simulacao. |
| `tools/vcs/run/` | Saida da simulacao. |
| `tools/dc_nxt/scripts/setup.tcl` | Caminhos, bibliotecas e variaveis da sintese. |
| `tools/dc_nxt/scripts/synth.tcl` | Passo a passo da sintese. |
| `tools/dc_nxt/run/` | Area de execucao do DC_NXT. |
| `tools/dc_nxt/rpt/` | Relatorios da sintese. |
| `tools/dc_nxt/outputs/` | Netlist, DDC, SDC final, SDF e SVF. |
