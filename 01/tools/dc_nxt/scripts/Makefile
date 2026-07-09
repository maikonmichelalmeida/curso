# ==============================================================================
# Makefile interno - Sintese DC_NXT
# ==============================================================================
#
# Este Makefile fica dentro da ferramenta, como no ambiente do professor.
# Ele prepara tools/dc_nxt/run e chama dcnxt_shell com o Tcl de sintese.

SHELL := /bin/bash

ROOT_DIR := ../../..
RUN_DIR  := ../run
RPT_DIR  := ../rpt
OUT_DIR  := ../outputs

SYNTH_SCRIPT := synth.tcl
DC_TOOL      ?= dcnxt_shell
DC_FLAGS     ?= -64bit -topo

# Caminho da biblioteca SAED visto pelo DC_NXT. A raiz repassa essa variavel.
SAED_REF ?= ../../../../../ref

.PHONY: help synth synth_gui setup run_synth clean

help:
	@echo "Makefile DC_NXT"
	@echo "  make synth                  Roda sintese batch"
	@echo "  make synth_gui              Abre DC_NXT em GUI"
	@echo "  make clean                  Limpa tools/dc_nxt/run"
	@echo
	@echo "Variaveis:"
	@echo "  SAED_REF=/caminho/para/ref  Caminho da biblioteca SAED"
	@echo "  DC_TOOL=dcnxt_shell         Ferramenta chamada"
	@echo "  DC_FLAGS='-64bit -topo'     Flags da ferramenta"

synth: setup run_synth

setup:
	@echo "--- [DC_NXT SETUP] Preparando diretorios ---"
	@mkdir -p $(RUN_DIR) $(RPT_DIR) $(OUT_DIR)
	@if [ ! -f "$(ROOT_DIR)/verif/filelist_rtl.f" ]; then echo "ERRO: filelist RTL nao encontrado"; exit 1; fi
	@echo "SAED_REF=$(SAED_REF)"

run_synth:
	@echo "--- [DC_NXT RUN] Rodando sintese batch ---"
	cd $(RUN_DIR) && SAED_REF="$(SAED_REF)" $(DC_TOOL) $(DC_FLAGS) -f ../scripts/$(SYNTH_SCRIPT) -output_log_file dc_synth.log

synth_gui: setup
	@echo "--- [DC_NXT GUI] Abrindo GUI no diretorio run ---"
	cd $(RUN_DIR) && SAED_REF="$(SAED_REF)" $(DC_TOOL) $(DC_FLAGS) -gui

clean:
	@echo "--- [DC_NXT CLEAN] Limpando $(RUN_DIR) ---"
	@rm -rf $(RUN_DIR)/*
