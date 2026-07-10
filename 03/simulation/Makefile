# ==============================================================================
# Lab 03 - Simulacao RTL do mini_datapath
# ==============================================================================
#
# Este Makefile cuida apenas da simulacao RTL.
#
# Por que manter simulacao e sintese separadas?
#
#   - simulacao RTL responde: "o comportamento funcional esta correto?"
#   - sintese responde: "a ferramenta consegue transformar isso em portas?"
#   - constraints respondem: "isso cabe no tempo fisico que eu declarei?"
#
# Antes de estudar constraints, rode este Makefile. Se a simulacao RTL falhar,
# nao faz sentido discutir timing ainda.

SHELL := /bin/bash

TEST     ?= mini_datapath
TOP      := tb_mini_datapath
FILELIST := filelist_mini_datapath.f
RUN_DIR  := run/$(TEST)
SIMV     := $(RUN_DIR)/simv
WAVE     := $(RUN_DIR)/$(TEST).fsdb

VCS_FLAGS  = -sverilog
VCS_FLAGS += -timescale=1ns/1ps
VCS_FLAGS += -debug_access+all
VCS_FLAGS += -kdb
VCS_FLAGS += -Mdir=$(RUN_DIR)/csrc
VCS_FLAGS += -l $(RUN_DIR)/comp.log

.PHONY: help doctor show setup comp sim waves test clean

help:
	@echo "Lab 03 - simulacao RTL do mini_datapath"
	@echo
	@echo "Sequencia recomendada:"
	@echo "  module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6"
	@echo "  make doctor"
	@echo "  make show"
	@echo "  make test"
	@echo "  make waves"
	@echo
	@echo "Arquivos gerados:"
	@echo "  $(RUN_DIR)/comp.log"
	@echo "  $(RUN_DIR)/sim.log"
	@echo "  $(RUN_DIR)/mini_datapath.fsdb"

doctor:
	@echo "--- [DOCTOR] Conferindo ambiente de simulacao ---"
	@command -v vcs >/dev/null 2>&1 && \
		echo "VCS: encontrado" || \
		echo "VCS: nao encontrado. Rode: module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6"
	@command -v verdi >/dev/null 2>&1 && \
		echo "Verdi: encontrado" || \
		echo "Verdi: nao encontrado. Rode: module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6"
	@[ -f "$(FILELIST)" ] && echo "Filelist: $(FILELIST)" || \
		(echo "ERRO: $(FILELIST) nao encontrado"; exit 1)

show:
	@echo "TEST:     $(TEST)"
	@echo "TOP:      $(TOP)"
	@echo "FILELIST: $(FILELIST)"
	@echo "RUN_DIR:  $(RUN_DIR)"
	@echo "SIMV:     $(SIMV)"
	@echo "WAVE:     $(WAVE)"

setup:
	@mkdir -p $(RUN_DIR)

comp: setup
	@echo "--- [COMP] Compilando RTL + testbench ---"
	@echo "Log de compilacao: $(RUN_DIR)/comp.log"
	vcs $(VCS_FLAGS) -f $(FILELIST) -top $(TOP) -o $(SIMV)

sim:
	@echo "--- [SIM] Executando simulacao RTL ---"
	@if [ ! -x "$(SIMV)" ]; then \
		echo "ERRO: $(SIMV) nao existe. Rode make comp antes."; \
		exit 1; \
	fi
	cd $(RUN_DIR) && ./simv -l sim.log

waves:
	@echo "--- [WAVES] Abrindo waveform no Verdi ---"
	@if [ ! -f "$(WAVE)" ]; then \
		echo "ERRO: waveform nao encontrada: $(WAVE). Rode make test antes."; \
		exit 1; \
	fi
	cd $(RUN_DIR) && verdi -dbdir simv.daidir -ssf $(TEST).fsdb &

test:
	@$(MAKE) --no-print-directory clean
	@$(MAKE) --no-print-directory comp
	@$(MAKE) --no-print-directory sim

clean:
	@echo "--- [CLEAN] Limpando simulacao do Lab 03 ---"
	rm -rf run
