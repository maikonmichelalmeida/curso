# ==============================================================================
# Lab 02 - Makefile simples para testar modulo por modulo
# ==============================================================================
#
# Este Makefile ainda e pequeno, mas da um passo em direcao aos labs:
#
#   1. cada teste escolhe um filelist;
#   2. cada teste escolhe um top de testbench;
#   3. cada teste gera seus arquivos dentro de run/<teste>/.
#
# Isso evita misturar os resultados de mux, alu, regbank, memory e top.
# Mais adiante, o ambiente do professor vai separar ainda mais as ferramentas.
# Por enquanto, so estamos aprendendo a organizar simulacoes RTL.
#
# Exemplos:
#
#   make test TEST=mux
#   make test TEST=alu
#   make test TEST=regbank
#   make test TEST=memory
#   make test TEST=top
#   make all
#
# Ainda nao ha Tcl, SDC, sintese, gate-level ou ambiente completo.

SHELL := /bin/bash

TEST ?= mux

TESTS := mux alu regbank memory top

FILELIST = filelist_$(TEST).f
RUN_ROOT = run
RUN_DIR  = $(RUN_ROOT)/$(TEST)
SIMV     = $(RUN_DIR)/simv
WAVE     = $(RUN_DIR)/$(TEST).fsdb

TOP_mux     = tb_mux
TOP_alu     = tb_alu
TOP_regbank = tb_regbank
TOP_memory  = tb_memory
TOP_top     = tb_top

TOP = $(TOP_$(TEST))

VCS_FLAGS = -sverilog -timescale=1ns/1ps -debug_access+all -kdb
VCS_FLAGS += -Mdir=$(RUN_DIR)/csrc
VCS_FLAGS += -l $(RUN_DIR)/comp.log

.PHONY: help list check doctor show setup comp sim waves test all clean clean-all

help:
	@echo "Lab 02 - testes RTL simples"
	@echo
	@echo "Uso principal:"
	@echo "  make test TEST=mux       Limpa, compila e simula o mux"
	@echo "  make test TEST=alu       Limpa, compila e simula a ALU"
	@echo "  make test TEST=regbank   Limpa, compila e simula o registrador"
	@echo "  make test TEST=memory    Limpa, compila e simula a memoria"
	@echo "  make test TEST=top       Limpa, compila e simula o top"
	@echo "  make all                 Roda todos os testes acima"
	@echo
	@echo "Passo a passo:"
	@echo "  module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6"
	@echo "  make show TEST=alu"
	@echo "  make comp TEST=alu"
	@echo "  make sim TEST=alu"
	@echo "  make waves TEST=alu"
	@echo
	@echo "Apoio:"
	@echo "  make list"
	@echo "  make doctor TEST=alu"
	@echo "  make clean TEST=alu"
	@echo "  make clean-all"

list:
	@echo "Testes disponiveis: $(TESTS)"

check:
	@if [ -z "$(TOP)" ]; then \
		echo "ERRO: TEST='$(TEST)' nao existe."; \
		echo "Use: make list"; \
		exit 1; \
	fi
	@if [ ! -f "$(FILELIST)" ]; then \
		echo "ERRO: filelist nao encontrado: $(FILELIST)"; \
		exit 1; \
	fi

doctor: check
	@echo "--- [DOCTOR] Conferindo ambiente para TEST=$(TEST) ---"
	@command -v vcs >/dev/null 2>&1 && \
		echo "VCS: encontrado" || \
		echo "VCS: nao encontrado. Rode: module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6"
	@command -v verdi >/dev/null 2>&1 && \
		echo "Verdi: encontrado" || \
		echo "Verdi: nao encontrado. Rode: module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6"
	@echo "Filelist: $(FILELIST)"
	@echo "Top:      $(TOP)"
	@echo "Run dir:  $(RUN_DIR)"

show: check
	@echo "TEST:     $(TEST)"
	@echo "TOP:      $(TOP)"
	@echo "FILELIST: $(FILELIST)"
	@echo "RUN_DIR:  $(RUN_DIR)"
	@echo "SIMV:     $(SIMV)"
	@echo "WAVE:     $(WAVE)"

setup: check
	@mkdir -p $(RUN_DIR)

comp: setup
	@echo "--- [COMP] TEST=$(TEST) TOP=$(TOP) FILELIST=$(FILELIST) ---"
	@echo "Saida da compilacao: $(RUN_DIR)/comp.log"
	vcs $(VCS_FLAGS) -f $(FILELIST) -top $(TOP) -o $(SIMV)

sim: check
	@echo "--- [SIM] TEST=$(TEST) ---"
	@if [ ! -x "$(SIMV)" ]; then \
		echo "ERRO: $(SIMV) nao existe. Rode make comp TEST=$(TEST) antes."; \
		exit 1; \
	fi
	cd $(RUN_DIR) && ./simv -l sim.log

waves: check
	@echo "--- [WAVES] TEST=$(TEST) WAVE=$(WAVE) ---"
	@if [ ! -f "$(WAVE)" ]; then \
		echo "ERRO: waveform nao encontrada: $(WAVE). Rode make sim TEST=$(TEST) antes."; \
		exit 1; \
	fi
	cd $(RUN_DIR) && verdi -dbdir simv.daidir -ssf $(TEST).fsdb &

test:
	@$(MAKE) --no-print-directory clean TEST=$(TEST)
	@$(MAKE) --no-print-directory comp TEST=$(TEST)
	@$(MAKE) --no-print-directory sim TEST=$(TEST)

all:
	@set -e; \
	for nome in $(TESTS); do \
		echo; \
		echo "============================================================"; \
		echo "Rodando TEST=$$nome"; \
		echo "============================================================"; \
		$(MAKE) --no-print-directory test TEST=$$nome; \
	done

clean:
	@echo "--- [CLEAN] Limpando run de TEST=$(TEST) ---"
	rm -rf $(RUN_DIR)

clean-all:
	@echo "--- [CLEAN-ALL] Limpando todos os runs ---"
	rm -rf $(RUN_ROOT)
