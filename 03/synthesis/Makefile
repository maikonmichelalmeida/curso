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

# Caminho para a pasta ref/ no estilo Design Compiler NXT.
#
# O material de DC NXT organiza a SAED32 assim:
#
#   ref/DBs/saed32lvt_ss0p75v125c.db
#   ref/CLIBs/saed32_lvt.ndm
#   ref/tech/saed32nm_1p9m.tf
#
# Por isso o parametro principal deste lab passa a ser REF_ROOT: a pasta ref.
# Se o servidor tiver a arvore completa do curso, sobrescreva assim:
#
#   make syn LEVEL=0 REF_ROOT=/caminho/para/ref
#
# REF_LIB ainda existe como compatibilidade com o lab 04 antigo, que usa:
#
#   ref/SAED32_2012-12-25/lib/stdcell_hvt/...
REF_ROOT ?= ../../Aulas2Prints/07 Design Compiler NXT - RTL Synthesis/07 DCNXT_2021.06/ref
REF_LIB  ?=

TARGET_DB  ?= saed32lvt_ss0p75v125c.db
DRIVE_LIB  ?= saed32lvt_ss0p75v125c
DRIVE_CELL ?= NBUFFX2_LVT
LOAD_CELL  ?= NBUFFX16_LVT

RUN_DIR = run/level$(LEVEL)

.PHONY: help doctor show find-lib setup syn gui clean clean-all

help:
	@echo "Lab 03 - sintese gradual com constraints"
	@echo
	@echo "Sequencia recomendada:"
	@echo "  module avail dc design compiler synopsys"
	@echo "  module load designcompiler/W-2024.09-SP5-4"
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
	@echo "  REF_ROOT=/caminho/para/ref"
	@echo "  TARGET_DB=saed32lvt_ss0p75v125c.db"
	@echo "  DRIVE_LIB=saed32lvt_ss0p75v125c"
	@echo "  DRIVE_CELL=NBUFFX2_LVT"
	@echo "  LOAD_CELL=NBUFFX16_LVT"
	@echo
	@echo "Apoio:"
	@echo "  make find-lib    Procura bibliotecas SAED32 em locais provaveis"

doctor:
	@echo "--- [DOCTOR] Conferindo ambiente de sintese ---"
	@command -v dc_shell >/dev/null 2>&1 && \
		echo "dc_shell: encontrado" || \
		echo "dc_shell: nao encontrado. Use module avail dc/design/compiler/synopsys e carregue Design Compiler/DC NXT."
	@if [ -f "$(REF_ROOT)/DBs/$(TARGET_DB)" ]; then \
		echo "REF_ROOT: $(REF_ROOT)"; \
		echo "TARGET_DB: $(TARGET_DB)"; \
	elif [ -n "$(REF_LIB)" ] && [ -d "$(REF_LIB)" ]; then \
		echo "REF_LIB legado: $(REF_LIB)"; \
	else \
		echo "ATENCAO: biblioteca SAED32 nao encontrada."; \
		echo "  Preferido: REF_ROOT=/caminho/para/ref contendo DBs/ CLIBs/ tech/"; \
		echo "  Alternativo: REF_LIB=/caminho/SAED32_2012-12-25"; \
		echo "  Rode: make find-lib"; \
	fi
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
	@echo "REF_ROOT:   $(REF_ROOT)"
	@echo "REF_LIB:    $(REF_LIB)  (legado, opcional)"
	@echo "TARGET_DB:  $(TARGET_DB)"
	@echo "DRIVE_LIB:  $(DRIVE_LIB)"
	@echo "DRIVE_CELL: $(DRIVE_CELL)"
	@echo "LOAD_CELL:  $(LOAD_CELL)"
	@echo "SCRIPT:     scripts/run_dc.tcl"
	@echo "CONSTRAINT: scripts/constraints_level$(LEVEL).tcl"

find-lib:
	@echo "--- [FIND-LIB] Procurando bibliotecas SAED32 ---"
	@echo "Isto pode demorar um pouco. Mensagens de permissao negada serao escondidas."
	@echo
	@find $$HOME /home/ciexpert /tools -type f \( \
		-name "saed32hvt_ss0p75v125c.db" -o \
		-name "saed32lvt_ss0p75v125c.db" -o \
		-name "saed32rvt_ss0p75v125c.db" -o \
		-name "saed32_lvt.ndm" -o \
		-name "saed32_hvt.ndm" -o \
		-name "saed32nm_1p9m.tf" -o \
		-name "saed32nm_hvt.v" -o \
		-name "saed32nm_lvt.v" \
	\) 2>/dev/null | sort || true
	@echo
	@echo "O material DC NXT espera algo como:"
	@echo "  ref/DBs/saed32lvt_ss0p75v125c.db"
	@echo "  ref/CLIBs/saed32_lvt.ndm"
	@echo "  ref/tech/saed32nm_1p9m.tf"
	@echo
	@echo "Se aparecer:"
	@echo "  .../ref/DBs/saed32lvt_ss0p75v125c.db"
	@echo "use REF_ROOT como a pasta ate ref."
	@echo
	@echo "Se aparecer:"
	@echo "  .../SAED32_2012-12-25/lib/stdcell_hvt/db_nldm/saed32hvt_ss0p75v125c.db"
	@echo "use REF_LIB como a pasta ate SAED32_2012-12-25."
	@echo
	@echo "Exemplo:"
	@echo "  make syn LEVEL=0 REF_ROOT=/caminho/ref"

setup:
	@mkdir -p $(RUN_DIR) reports mapped unmapped

syn: setup
	@echo "--- [SYN] Rodando Design Compiler para LEVEL=$(LEVEL) ---"
	@echo "Log principal: $(RUN_DIR)/dc_level$(LEVEL).log"
	dc_shell -x "set LAB_LEVEL $(LEVEL); set DESIGN_TOP $(TOP); set DESIGN_WIDTH $(WIDTH); set REF_ROOT_PATH {$(REF_ROOT)}; set REF_LIB_PATH {$(REF_LIB)}; set TARGET_DB_NAME {$(TARGET_DB)}; set DRIVE_LIB_NAME {$(DRIVE_LIB)}; set DRIVE_CELL_NAME {$(DRIVE_CELL)}; set LOAD_CELL_NAME {$(LOAD_CELL)}; source -e -v scripts/run_dc.tcl" | tee $(RUN_DIR)/dc_level$(LEVEL).log

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
