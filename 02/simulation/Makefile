# ==============================================================================
# Lab 02 - Makefile simples para testar modulo por modulo
# ==============================================================================
#
# Este Makefile continua bem perto do Lab 01.
# A unica novidade e a variavel TEST.
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
WAVE     = $(TEST).fsdb

TOP_mux     = tb_mux
TOP_alu     = tb_alu
TOP_regbank = tb_regbank
TOP_memory  = tb_memory
TOP_top     = tb_top

TOP = $(TOP_$(TEST))

VCS_FLAGS = -sverilog -timescale=1ns/1ps -debug_access+all -kdb -l comp.log

.PHONY: help list check comp sim waves test all clean

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
	@echo "  make comp TEST=alu"
	@echo "  make sim TEST=alu"
	@echo "  make waves TEST=alu"
	@echo
	@echo "Apoio:"
	@echo "  make list"
	@echo "  make clean"

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

comp: check
	@echo "--- [COMP] TEST=$(TEST) TOP=$(TOP) FILELIST=$(FILELIST) ---"
	vcs $(VCS_FLAGS) -f $(FILELIST) -top $(TOP)

sim: check
	@echo "--- [SIM] TEST=$(TEST) ---"
	@if [ ! -x "simv" ]; then \
		echo "ERRO: simv nao existe. Rode make comp TEST=$(TEST) antes."; \
		exit 1; \
	fi
	./simv -l sim.log

waves: check
	@echo "--- [WAVES] TEST=$(TEST) WAVE=$(WAVE) ---"
	@if [ ! -f "$(WAVE)" ]; then \
		echo "ERRO: waveform nao encontrada: $(WAVE). Rode make sim TEST=$(TEST) antes."; \
		exit 1; \
	fi
	verdi -dbdir simv.daidir -ssf $(WAVE) &

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
	@echo "--- [CLEAN] Limpando arquivos gerados ---"
	rm -rf simv* csrc* *.log *.fsdb *.vcd *.vpd *.key ucli.key novas.* verdiLog AN.DB DVEfiles *.daidir
