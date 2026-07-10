# ==============================================================================
# Lab 03 - Sintese gradual com constraints
# ==============================================================================
#
# Este Makefile e inspirado no lab 04 ces_svrtl_2019.03, mas reduzido para o
# nosso mini_datapath. A ideia e aprender Design Compiler/TCL em camadas.
#
# Comando principal:
#
#   make syn LEVEL=0
#   make syn LEVEL=1
#   make syn LEVEL=2
#   make syn LEVEL=3
#   make syn LEVEL=4
#   make syn LEVEL=5
#   make syn LEVEL=6
#
# Cada LEVEL escolhe um arquivo de constraints diferente:
#
#   0 -> sem constraints reais
#   1 -> create_clock
#   2 -> clock + input/output delay
#   3 -> acrescenta uncertainty, latency e transition
#   4 -> acrescenta driving cell e load
#   5 -> mesmo conteudo do nivel 4, mas com reports mais guiados
#   6 -> experimento: clock mais apertado para estudar violacao
#
# Observacao:
#   Este Makefile pressupoe que voce esta no servidor com dc_shell disponivel.
#   No Windows local ele serve como roteiro/documentacao.

SHELL := /bin/bash

LEVEL ?= 0
WIDTH ?= 8
TOP   ?= mini_datapath

# Caminho para a biblioteca SAED32 usada pelo lab 04 da Synopsys.
# No servidor, se esse caminho for diferente, voce pode sobrescrever:
#
#   make syn LEVEL=1 REF_LIB=/caminho/para/SAED32_2012-12-25
#
# O caminho padrao abaixo funciona quando este curso esta ao lado da pasta
# Aulas2Prints dentro de ~/ci_expert.
REF_LIB ?= ../../Aulas2Prints/04 RTL Design Synthesis/04 ces_svrtl_2019.03/ref/SAED32_2012-12-25

RUN_DIR = run/level$(LEVEL)

.PHONY: help doctor show setup syn gui clean clean-all

help:
	@echo "Lab 03 - sintese gradual com constraints"
	@echo
	@echo "Sequencia recomendada:"
	@echo "  make doctor"
	@echo "  make show LEVEL=0"
	@echo "  make syn  LEVEL=0"
	@echo "  make syn  LEVEL=1"
	@echo "  make syn  LEVEL=2"
	@echo "  make syn  LEVEL=3"
	@echo "  make syn  LEVEL=4"
	@echo "  make syn  LEVEL=5"
	@echo "  make syn  LEVEL=6"
	@echo
	@echo "Parametros uteis:"
	@echo "  LEVEL=0..6"
	@echo "  WIDTH=8, 12, 16..."
	@echo "  REF_LIB=/caminho/SAED32_2012-12-25"

doctor:
	@echo "--- [DOCTOR] Conferindo ambiente de sintese ---"
	@command -v dc_shell >/dev/null 2>&1 && \
		echo "dc_shell: encontrado" || \
		echo "dc_shell: nao encontrado. Carregue Design Compiler/DC NXT."
	@[ -d "$(REF_LIB)" ] && \
		echo "REF_LIB: $(REF_LIB)" || \
		echo "ATENCAO: REF_LIB nao encontrado: $(REF_LIB)"
	@[ -f "../rtl/mini_datapath.sv" ] && echo "RTL: encontrado" || \
		(echo "ERRO: RTL nao encontrado"; exit 1)
	@[ -f "scripts/constraints_level$(LEVEL).tcl" ] && \
		echo "Constraints: scripts/constraints_level$(LEVEL).tcl" || \
		(echo "ERRO: nivel $(LEVEL) nao existe"; exit 1)

show:
	@echo "TOP:        $(TOP)"
	@echo "WIDTH:      $(WIDTH)"
	@echo "LEVEL:      $(LEVEL)"
	@echo "RUN_DIR:    $(RUN_DIR)"
	@echo "REF_LIB:    $(REF_LIB)"
	@echo "SCRIPT:     scripts/run_dc.tcl"
	@echo "CONSTRAINT: scripts/constraints_level$(LEVEL).tcl"

setup:
	@mkdir -p $(RUN_DIR) reports mapped unmapped

syn: setup
	@echo "--- [SYN] Rodando Design Compiler para LEVEL=$(LEVEL) ---"
	@echo "Log principal: $(RUN_DIR)/dc_level$(LEVEL).log"
	dc_shell -x "set LAB_LEVEL $(LEVEL); set DESIGN_TOP $(TOP); set DESIGN_WIDTH $(WIDTH); set REF_LIB_PATH {$(REF_LIB)}; source -e -v scripts/run_dc.tcl" | tee $(RUN_DIR)/dc_level$(LEVEL).log

gui:
	@echo "--- [GUI] Abrindo Design Vision para o DDC mapeado do nivel $(LEVEL) ---"
	dc_shell -x "read_ddc mapped/$(TOP)_level$(LEVEL)_mapped.ddc; start_gui"

clean:
	@echo "--- [CLEAN] Limpando nivel $(LEVEL) ---"
	rm -rf $(RUN_DIR)
	rm -f reports/*level$(LEVEL)* mapped/*level$(LEVEL)* unmapped/*level$(LEVEL)*

clean-all:
	@echo "--- [CLEAN-ALL] Limpando toda a sintese do Lab 03 ---"
	rm -rf run reports mapped unmapped *.log *.svf command.log default.svf filenames.log
	mkdir -p reports mapped unmapped
