# ==============================================================================
# Lab 03 - Sintese gradual com constraints
# ==============================================================================
#
# Uso principal:
#
#   module load designcompiler/W-2024.09-SP5-4
#   make doctor
#   make show LEVEL=0
#   make syn  LEVEL=0
#
# Estrutura recomendada:
#
#   curso/03/
#   |-- rtl/
#   |-- simulation/
#   |-- synthesis/        <- este Makefile
#   `-- ref/
#       |-- DBs/saed32lvt_ss0p75v125c.db
#       |-- CLIBs/saed32_lvt.ndm
#       `-- tech/...
#
# Caso a biblioteca esteja em outro local:
#
#   make doctor REF_ROOT=/caminho/para/ref
#   make syn LEVEL=0 REF_ROOT=/caminho/para/ref
#
# REF_LIB permanece disponivel somente para compatibilidade com o lab antigo:
#
#   make syn LEVEL=0 REF_LIB=/caminho/SAED32_2012-12-25

SHELL := /bin/bash

LEVEL ?= 0
WIDTH ?= 8
TOP   ?= mini_datapath

# A pasta ref fica, por padrao, ao lado das pastas rtl/, simulation/ e synthesis/.
REF_ROOT ?= ../ref
REF_LIB  ?=

TARGET_DB  ?= saed32lvt_ss0p75v125c.db
DRIVE_LIB  ?= saed32lvt_ss0p75v125c
DRIVE_CELL ?= NBUFFX2_LVT
LOAD_CELL  ?= NBUFFX16_LVT

# Busca controlada. Nao varre todo o /tools indefinidamente.
SEARCH_ROOTS  ?= $(HOME) /home/ciexpert /tools/pdk/synopsys /tools/synopsys
FIND_TIMEOUT  ?= 30
FIND_MAXDEPTH ?= 10

RUN_DIR = run/level$(LEVEL)

# Caminhos normalizados. Continuam aceitando REF_ROOT informado na linha de comando.
REF_ROOT_ABS := $(abspath $(REF_ROOT))
REF_LIB_ABS  := $(if $(strip $(REF_LIB)),$(abspath $(REF_LIB)),)
TARGET_DB_PATH := $(REF_ROOT_ABS)/DBs/$(TARGET_DB)
CONSTRAINT_FILE := scripts/constraints_level$(LEVEL).tcl
RTL_FILE := ../rtl/mini_datapath.sv

.PHONY: help doctor show find-lib setup syn gui clean clean-all

help:
	@echo "Lab 03 - sintese gradual com constraints"
	@echo
	@echo "Preparacao recomendada:"
	@echo "  1. module load designcompiler/W-2024.09-SP5-4"
	@echo "  2. coloque a pasta ref em ../ref"
	@echo "  3. make doctor"
	@echo "  4. make syn LEVEL=0"
	@echo
	@echo "Niveis disponiveis:"
	@echo "  make syn LEVEL=0   Sem constraints reais"
	@echo "  make syn LEVEL=1   Clock"
	@echo "  make syn LEVEL=2   Clock + delays de I/O"
	@echo "  make syn LEVEL=3   Uncertainty, latency e transition"
	@echo "  make syn LEVEL=4   Driving cell e load"
	@echo "  make syn LEVEL=5   Reports guiados"
	@echo "  make syn LEVEL=6   Clock apertado para estudar violacao"
	@echo
	@echo "Parametros uteis:"
	@echo "  LEVEL=0..6"
	@echo "  WIDTH=8, 12, 16..."
	@echo "  REF_ROOT=/caminho/para/ref"
	@echo "  REF_LIB=/caminho/SAED32_2012-12-25  (legado)"
	@echo "  TARGET_DB=saed32lvt_ss0p75v125c.db"
	@echo "  DRIVE_LIB=saed32lvt_ss0p75v125c"
	@echo "  DRIVE_CELL=NBUFFX2_LVT"
	@echo "  LOAD_CELL=NBUFFX16_LVT"
	@echo
	@echo "Diagnostico:"
	@echo "  make doctor"
	@echo "  make show LEVEL=0"
	@echo "  make find-lib"

# Verifica tudo o que e obrigatorio antes da sintese.
# Retorna erro quando algo essencial estiver ausente.
doctor:
	@echo "--- [DOCTOR] Conferindo ambiente de sintese ---"; \
	status=0; \
	if command -v dc_shell >/dev/null 2>&1; then \
		echo "OK: dc_shell encontrado em $$(command -v dc_shell)"; \
	else \
		echo "ERRO: dc_shell nao encontrado."; \
		echo "  Rode: module load designcompiler/W-2024.09-SP5-4"; \
		status=1; \
	fi; \
	if [ -f "$(TARGET_DB_PATH)" ]; then \
		echo "OK: TARGET_DB encontrado"; \
		echo "    $(TARGET_DB_PATH)"; \
	elif [ -n "$(REF_LIB_ABS)" ] && [ -d "$(REF_LIB_ABS)" ]; then \
		echo "OK: REF_LIB legado encontrado"; \
		echo "    $(REF_LIB_ABS)"; \
	else \
		echo "ERRO: biblioteca SAED32 nao encontrada."; \
		echo "  Caminho esperado: $(TARGET_DB_PATH)"; \
		echo "  Opcao 1: coloque a pasta ref em $(REF_ROOT_ABS)"; \
		echo "  Opcao 2: make doctor REF_ROOT=/caminho/para/ref"; \
		echo "  Para procurar com limites: make find-lib"; \
		status=1; \
	fi; \
	if [ -f "$(RTL_FILE)" ]; then \
		echo "OK: RTL encontrado: $(RTL_FILE)"; \
	else \
		echo "ERRO: RTL nao encontrado: $(RTL_FILE)"; \
		status=1; \
	fi; \
	if [ -f "$(CONSTRAINT_FILE)" ]; then \
		echo "OK: constraints encontradas: $(CONSTRAINT_FILE)"; \
	else \
		echo "ERRO: LEVEL=$(LEVEL) nao existe: $(CONSTRAINT_FILE)"; \
		status=1; \
	fi; \
	if [ $$status -eq 0 ]; then \
		echo "DOCTOR_RESULT: PASS"; \
	else \
		echo "DOCTOR_RESULT: FAIL"; \
	fi; \
	exit $$status

show:
	@echo "TOP:          $(TOP)"
	@echo "WIDTH:        $(WIDTH)"
	@echo "LEVEL:        $(LEVEL)"
	@echo "RUN_DIR:      $(RUN_DIR)"
	@echo "REF_ROOT:     $(REF_ROOT_ABS)"
	@echo "REF_LIB:      $(REF_LIB_ABS)  (legado, opcional)"
	@echo "TARGET_DB:    $(TARGET_DB)"
	@echo "TARGET_PATH:  $(TARGET_DB_PATH)"
	@echo "DRIVE_LIB:    $(DRIVE_LIB)"
	@echo "DRIVE_CELL:   $(DRIVE_CELL)"
	@echo "LOAD_CELL:    $(LOAD_CELL)"
	@echo "SCRIPT:       scripts/run_dc.tcl"
	@echo "CONSTRAINT:   $(CONSTRAINT_FILE)"

# Procura a SAED32 somente em locais provaveis, com profundidade e tempo limitados.
# Cada raiz recebe no maximo FIND_TIMEOUT segundos.
find-lib:
	@echo "--- [FIND-LIB] Procurando bibliotecas SAED32 com limites ---"
	@echo "Raizes: $(SEARCH_ROOTS)"
	@echo "Limite: $(FIND_TIMEOUT)s por raiz; profundidade maxima: $(FIND_MAXDEPTH)"
	@echo
	@tmp=$$(mktemp); \
	for root in $(SEARCH_ROOTS); do \
		if [ -d "$$root" ]; then \
			echo "Procurando em: $$root" >&2; \
			timeout "$(FIND_TIMEOUT)s" find "$$root" \
				-xdev \
				-maxdepth "$(FIND_MAXDEPTH)" \
				\( -type f -o -type d \) \
				\( \
					-name "saed32hvt_ss0p75v125c.db" -o \
					-name "saed32lvt_ss0p75v125c.db" -o \
					-name "saed32rvt_ss0p75v125c.db" -o \
					-name "saed32_lvt.ndm" -o \
					-name "saed32_hvt.ndm" -o \
					-name "saed32nm_1p9m.tf" -o \
					-name "saed32nm_1p9m_Cmax.tluplus" -o \
					-name "saed32nm_tf_itf_tluplus.map" -o \
					-name "saed32nm_hvt.v" -o \
					-name "saed32nm_lvt.v" \
				\) -print 2>/dev/null >> "$$tmp" || true; \
		fi; \
	done; \
	sort -u "$$tmp"; \
	if [ ! -s "$$tmp" ]; then \
		echo; \
		echo "Nenhum arquivo SAED32 foi encontrado nos locais pesquisados."; \
		echo "Voce precisara obter a pasta ref do pacote original do laboratorio."; \
	else \
		echo; \
		echo "Se apareceu .../ref/DBs/$(TARGET_DB), use:"; \
		echo "  make doctor REF_ROOT=/caminho/terminado/em/ref"; \
		echo "  make syn LEVEL=0 REF_ROOT=/caminho/terminado/em/ref"; \
	fi; \
	rm -f "$$tmp"

setup:
	@mkdir -p "$(RUN_DIR)" reports mapped unmapped

# doctor e executado antes da sintese. Se a biblioteca estiver ausente,
# o fluxo para aqui, em vez de abrir o dc_shell para falhar mais adiante.
syn: doctor setup
	@echo "--- [SYN] Rodando Design Compiler para LEVEL=$(LEVEL) ---"
	@echo "Log principal: $(RUN_DIR)/dc_level$(LEVEL).log"
	dc_shell -x "set LAB_LEVEL $(LEVEL); set DESIGN_TOP $(TOP); set DESIGN_WIDTH $(WIDTH); set REF_ROOT_PATH {$(REF_ROOT_ABS)}; set REF_LIB_PATH {$(REF_LIB_ABS)}; set TARGET_DB_NAME {$(TARGET_DB)}; set DRIVE_LIB_NAME {$(DRIVE_LIB)}; set DRIVE_CELL_NAME {$(DRIVE_CELL)}; set LOAD_CELL_NAME {$(LOAD_CELL)}; source -e -v scripts/run_dc.tcl" | tee "$(RUN_DIR)/dc_level$(LEVEL).log"

gui:
	@if [ ! -f "mapped/$(TOP)_level$(LEVEL)_mapped.ddc" ]; then \
		echo "ERRO: DDC nao encontrado: mapped/$(TOP)_level$(LEVEL)_mapped.ddc"; \
		echo "Rode primeiro: make syn LEVEL=$(LEVEL)"; \
		exit 1; \
	fi
	@echo "--- [GUI] Abrindo Design Vision para o DDC mapeado do nivel $(LEVEL) ---"
	dc_shell -x "read_ddc mapped/$(TOP)_level$(LEVEL)_mapped.ddc; start_gui"

clean:
	@echo "--- [CLEAN] Limpando nivel $(LEVEL) ---"
	rm -rf "$(RUN_DIR)"
	rm -f reports/*level$(LEVEL)* mapped/*level$(LEVEL)* unmapped/*level$(LEVEL)*

clean-all:
	@echo "--- [CLEAN-ALL] Limpando toda a sintese do Lab 03 ---"
	rm -rf run reports mapped unmapped *.log *.svf command.log default.svf filenames.log
	mkdir -p reports mapped unmapped
