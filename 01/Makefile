# ==============================================================================
# Lab 01 - Esqueleto minimo do ambiente do professor
# ==============================================================================
#
# Este Makefile fica na raiz do bloco, como no ambiente do professor.
# Ele nao compila nada diretamente. A funcao dele e orquestrar:
#
#   make sim    -> entra em tools/vcs/scripts e chama o Makefile do VCS
#   make synth  -> entra em tools/dc_nxt/scripts e chama o Makefile do DC_NXT
#   make clean  -> pede para cada ferramenta limpar sua propria pasta run
#
# A ideia didatica e separar responsabilidades:
#
#   raiz do bloco      : comandos humanos curtos
#   rtl/               : design em SystemVerilog
#   verif/             : testbench e filelists
#   constraints/       : SDC, ou seja, contexto de timing
#   tools/vcs/scripts  : receita da simulacao
#   tools/dc_nxt/scripts: receita da sintese

SHELL := /bin/bash

# Modulos observados no ambiente do professor. Se algum nome mudar no servidor,
# ajuste aqui ou rode com USE_MODULES=0 depois de carregar os modulos manualmente.
MODULES ?= \
    syn/W-2024.09-SP5-2 \
    fusioncompiler/W-2024.09-SP3 \
    designcompiler/W-2024.09-SP5-4 \
    vcs/W-2024.09-SP2-3 \
    verdi/W-2024.09-SP2-6 \
    fm/W-2024.09-SP5

# USE_MODULES=1 tenta carregar modulos automaticamente.
# USE_MODULES=0 assume que voce ja carregou as ferramentas no terminal.
USE_MODULES ?= 1

# Caminho da biblioteca SAED. No ambiente do professor, a pasta ref costuma ficar
# alguns niveis acima do bloco. Se no servidor ela estiver em outro lugar, rode:
#
#   make synth SAED_REF=/caminho/para/ref
#
# O DC_NXT usa subpastas como DBs, CLIBs e tech dentro desse ref.
SAED_REF ?= ../../../../../ref

.PHONY: help show doctor sim waves synth synth_gui clean clean_all

help:
	@echo "Lab 01 - esqueleto minimo do ambiente"
	@echo
	@echo "Comandos principais:"
	@echo "  make show                 Mostra a estrutura do bloco"
	@echo "  make doctor               Checa comandos e caminho SAED_REF"
	@echo "  make sim                  Roda simulacao RTL com VCS"
	@echo "  make waves                Abre a waveform da ultima simulacao"
	@echo "  make synth                Roda sintese com DC_NXT"
	@echo "  make synth_gui            Abre DC_NXT em GUI ja no diretorio correto"
	@echo "  make clean                Limpa arquivos gerados pelas ferramentas"
	@echo
	@echo "Variaveis uteis:"
	@echo "  USE_MODULES=0             Nao chama module load automaticamente"
	@echo "  SAED_REF=/caminho/ref     Informa onde esta a biblioteca SAED"
	@echo
	@echo "Roteiro de estudo:"
	@echo "  leia docs/guia_lab.md antes de rodar os comandos"

show:
	@echo "Estrutura do Lab 01:"
	@echo "  rtl/lab01_top.sv                  Design pequeno em SystemVerilog"
	@echo "  verif/top_tb.sv                   Testbench simples"
	@echo "  verif/filelist.f                  Lista para simulacao VCS"
	@echo "  verif/filelist_rtl.f              Lista para sintese DC_NXT"
	@echo "  constraints/constraints.sdc       Constraints de timing"
	@echo "  tools/vcs/scripts/Makefile        Receita da simulacao"
	@echo "  tools/dc_nxt/scripts/Makefile     Receita da sintese"
	@echo "  tools/dc_nxt/scripts/setup.tcl     Setup de biblioteca e caminhos"
	@echo "  tools/dc_nxt/scripts/synth.tcl     Fluxo de sintese"

doctor:
	@echo "--- Checagem rapida do ambiente ---"
	@command -v module >/dev/null 2>&1 && echo "module: encontrado" || echo "module: nao encontrado neste shell"
	@command -v vcs >/dev/null 2>&1 && echo "vcs: encontrado" || echo "vcs: nao encontrado agora"
	@command -v verdi >/dev/null 2>&1 && echo "verdi: encontrado" || echo "verdi: nao encontrado agora"
	@command -v dcnxt_shell >/dev/null 2>&1 && echo "dcnxt_shell: encontrado" || echo "dcnxt_shell: nao encontrado agora"
	@echo
	@echo "SAED_REF atual: $(SAED_REF)"
	@if [ -d "$(SAED_REF)" ]; then echo "SAED_REF: diretorio encontrado"; else echo "SAED_REF: diretorio nao encontrado"; fi
	@if [ -f "$(SAED_REF)/DBs/saed32lvt_ss0p75v125c.db" ]; then echo "DB logica: encontrada"; else echo "DB logica: nao encontrada em $(SAED_REF)/DBs"; fi
	@if [ -f "$(SAED_REF)/tech/saed32nm_1p9m.tf" ]; then echo "Tech file: encontrado"; else echo "Tech file: nao encontrado em $(SAED_REF)/tech"; fi

sim:
	@echo "--- [RAIZ] Chamando simulacao VCS ---"
	@set -e; \
	if [ "$(USE_MODULES)" = "1" ]; then module load $(MODULES); fi; \
	cd tools/vcs/scripts && $(MAKE) sim

waves:
	@echo "--- [RAIZ] Abrindo waveform da simulacao RTL ---"
	@set -e; \
	if [ "$(USE_MODULES)" = "1" ]; then module load $(MODULES); fi; \
	cd tools/vcs/scripts && $(MAKE) waves

synth:
	@echo "--- [RAIZ] Chamando sintese DC_NXT ---"
	@set -e; \
	if [ "$(USE_MODULES)" = "1" ]; then module load $(MODULES); fi; \
	cd tools/dc_nxt/scripts && $(MAKE) synth SAED_REF="$(SAED_REF)"

synth_gui:
	@echo "--- [RAIZ] Abrindo DC_NXT em modo grafico ---"
	@set -e; \
	if [ "$(USE_MODULES)" = "1" ]; then module load $(MODULES); fi; \
	cd tools/dc_nxt/scripts && $(MAKE) synth_gui SAED_REF="$(SAED_REF)"

clean:
	@echo "--- [RAIZ] Limpando runs de VCS e DC_NXT ---"
	@cd tools/vcs/scripts && $(MAKE) clean
	@cd tools/dc_nxt/scripts && $(MAKE) clean

clean_all: clean
	@rm -rf tools/dc_nxt/outputs/* tools/dc_nxt/rpt/*
