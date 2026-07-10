# ==============================================================================
# Lab 01 - Makefile minimo para VCS e Verdi
# ==============================================================================
#
# Este Makefile e intencionalmente pequeno.
#
# A ideia e aprender apenas quatro alvos:
#
#   make comp   -> compila usando o filelist.f
#   make sim    -> executa o simulador gerado, chamado simv
#   make waves  -> abre o arquivo mux4.fsdb no Verdi
#   make clean  -> apaga arquivos gerados
#
# Nada de Tcl, nada de sintese, nada de constraints.

SHELL := /bin/bash

FILELIST := filelist.f
TOP      := tb_mux4
SIMV     := simv
WAVE     := mux4.fsdb

# Flags minimas:
# -sverilog          habilita SystemVerilog
# -timescale         define unidade/precisao de tempo
# -debug_access+all  permite debug e waveform com mais informacao
# -kdb               gera base de dados util para Verdi
# -l comp.log        salva log da compilacao
VCS_FLAGS := -sverilog -timescale=1ns/1ps -debug_access+all -kdb -l comp.log

.PHONY: help comp sim test waves clean

help:
	@echo "Lab 01 - mux 4:1"
	@echo
	@echo "Comandos:"
	@echo "  make comp    Compila o testbench e o RTL com VCS"
	@echo "  make sim     Executa ./simv e grava sim.log"
	@echo "  make test    Limpa, compila e simula"
	@echo "  make waves   Abre mux4.fsdb no Verdi"
	@echo "  make clean   Remove arquivos gerados"
	@echo
	@echo "Arquivos principais:"
	@echo "  ../tb/tb_mux4.sv"
	@echo "  ../rtl/mux4.sv"
	@echo "  filelist.f"

comp:
	@echo "--- [COMP] VCS lendo $(FILELIST) ---"
	vcs $(VCS_FLAGS) -f $(FILELIST) -top $(TOP)

sim:
	@echo "--- [SIM] Executando $(SIMV) ---"
	@if [ ! -x "$(SIMV)" ]; then \
		echo "ERRO: $(SIMV) nao existe. Rode make comp antes."; \
		exit 1; \
	fi
	./$(SIMV) -l sim.log

test: clean comp sim

waves:
	@echo "--- [WAVES] Abrindo $(WAVE) ---"
	@if [ ! -f "$(WAVE)" ]; then \
		echo "ERRO: $(WAVE) nao existe. Rode make sim antes."; \
		exit 1; \
	fi
	verdi -ssf $(WAVE) &

clean:
	@echo "--- [CLEAN] Removendo arquivos gerados ---"
	rm -rf simv* csrc* *.log *.fsdb *.vcd *.vpd *.key ucli.key novas.* verdiLog AN.DB DVEfiles *.daidir
