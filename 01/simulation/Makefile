# ==============================================================================
# Lab 01 - Makefile minimo baseado no lab SystemVerilog da Synopsys
# ==============================================================================
#
# Nesta primeira etapa o Makefile so faz tres coisas:
#   1. compila os arquivos listados em reg_array.f;
#   2. roda o executavel simv criado pelo VCS;
#   3. abre a waveform no Verdi.
#
# Sem sintese, sem constraints, sem Tcl, sem ambiente completo.

SHELL := /bin/bash

FILELIST := reg_array.f
SIMV     := simv
WAVE     := reg_array.fsdb

VCS_FLAGS := -sverilog -debug_access+all -kdb -l comp.log

.PHONY: help comp sim test waves clean

help:
	@echo "Lab 01 - primeiro Makefile"
	@echo
	@echo "Comandos:"
	@echo "  make comp    Compila com VCS usando reg_array.f"
	@echo "  make sim     Executa ./simv e grava sim.log"
	@echo "  make test    Limpa, compila e simula"
	@echo "  make waves   Abre reg_array.fsdb no Verdi"
	@echo "  make clean   Remove arquivos gerados"

comp:
	@echo "--- [COMP] VCS lendo $(FILELIST) ---"
	vcs $(VCS_FLAGS) -f $(FILELIST)

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
	@echo "--- [CLEAN] Limpando arquivos gerados ---"
	rm -rf simv* csrc* *.log ucli.key novas.* verdiLog *.fsdb *.vcd *.daidir DVEfiles
