# ==============================================================================
# Makefile interno - Simulacao VCS
# ==============================================================================
#
# Este arquivo imita a ideia do ambiente do professor:
# - a raiz chama "make sim";
# - a raiz entra aqui;
# - este Makefile conhece detalhes do VCS;
# - tudo que o VCS gera fica em tools/vcs/run.

SHELL := /bin/bash

ROOT_DIR  := ../../..
VERIF_DIR := $(ROOT_DIR)/verif
RUN_DIR   := ../run

FILELIST := $(VERIF_DIR)/filelist.f
TOP_TB   ?= top_tb

GUI ?= 0
COV ?= 0

VCS_FLAGS := -full64 -sverilog -timescale=1ns/1ps -debug_access+all -kdb
COMP_ARGS :=
RUN_ARGS  :=

ifeq ($(GUI),1)
	RUN_ARGS += -gui=verdi
endif

ifeq ($(COV),1)
	COV_METRICS := line+cond+fsm+tgl+branch
	COMP_ARGS += -cm $(COV_METRICS)
	RUN_ARGS  += -cm $(COV_METRICS) -cm_name $(TOP_TB)
endif

.PHONY: help sim setup comp run waves clean

help:
	@echo "Makefile VCS"
	@echo "  make sim          Compila e roda simulacao RTL"
	@echo "  make waves        Abre tools/vcs/run/top_rtl.fsdb no Verdi"
	@echo "  make sim GUI=1    Roda abrindo GUI do Verdi"
	@echo "  make sim COV=1    Liga cobertura basica"
	@echo "  make clean        Limpa tools/vcs/run"

sim: setup comp run

setup:
	@echo "--- [VCS SETUP] Preparando $(RUN_DIR) ---"
	@mkdir -p $(RUN_DIR)
	@if [ ! -f "$(FILELIST)" ]; then echo "ERRO: filelist nao encontrado: $(FILELIST)"; exit 1; fi

comp:
	@echo "--- [VCS COMP] Compilando a partir do filelist ---"
	cd $(RUN_DIR) && vcs $(VCS_FLAGS) $(COMP_ARGS) -f $(FILELIST) -top $(TOP_TB) -l vcs_compile.log

run:
	@echo "--- [VCS RUN] Executando simv ---"
	cd $(RUN_DIR) && ./simv $(RUN_ARGS) -l vcs_run.log

waves:
	@if [ ! -f "$(RUN_DIR)/top_rtl.fsdb" ]; then \
		echo "ERRO: waveform nao encontrada. Rode make sim primeiro."; \
		exit 1; \
	fi
	cd $(RUN_DIR) && verdi -ssf top_rtl.fsdb &

clean:
	@echo "--- [VCS CLEAN] Limpando $(RUN_DIR) ---"
	@rm -rf $(RUN_DIR)/*
