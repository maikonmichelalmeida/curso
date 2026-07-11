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
# A pasta ref nao e criada pelo Design Compiler. Ela precisa existir antes da
# sintese, porque vem do pacote/ambiente de bibliotecas da tecnologia.
#
# Para este lab, o caminho limpo e criar um link simbolico:
#
#   curso/03/ref -> /caminho/para/pasta/ref/fornecida
#
# Depois disso os comandos ficam sempre iguais:
#
#   make doctor
#   make syn LEVEL=0
#
# Caso queira testar sem criar o link:
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

TARGET_DB  ?= saed32lvt_ss0p75v125c.db
DRIVE_LIB  ?= saed32lvt_ss0p75v125c
DRIVE_CELL ?= NBUFFX2_LVT
LOAD_CELL  ?= NBUFFX16_LVT

# A pasta ref esperada pelo lab.
#
# O material da aula "Design Setup for Physical Synthesis" mostra que os
# arquivos de tecnologia devem ser organizados em pastas como DBs, CLIBs e tech.
# Por isso o Lab 03 espera:
#
#   ../ref/DBs/$(TARGET_DB)
#   ../ref/CLIBs/saed32_lvt.ndm
#   ../ref/tech/saed32nm_1p9m.tf
#
# Este e o procedimento didatico correto: primeiro preparar a arvore ref,
# depois rodar a sintese. O Makefile nao usa automaticamente caminhos antigos.
REF_ROOT ?= ../ref
REF_LIB  ?=

# Fonte da pasta ref fornecida/preparada para o laboratorio.
#
# Nao ha valor padrao propositalmente: a aula ensina a estrutura esperada
# (DBs/CLIBs/tech), mas nao define de onde voce recebeu esses arquivos.
# Depois que make find-lib localizar uma pasta valida, passe-a explicitamente:
#
#   make link-ref SAED32_SOURCE_REF=/caminho/terminado/em/ref
SAED32_SOURCE_REF ?=

# Physical setup:
#
# Os primeiros niveis deste lab usam sintese logica com dc_shell. A aula tambem
# mostra create_lib/open_lib, NDM, technology file e TLUPlus para sintese fisica
# em DC NXT/topographical. Mantemos essa preparacao documentada em dc_setup.tcl,
# mas ela fica desligada por padrao para nao misturar etapas.
#
# Use ENABLE_PHYSICAL_SETUP=1 somente quando quiser estudar essa etapa.
ENABLE_PHYSICAL_SETUP ?= 0

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
REF_DB_DIR := $(REF_ROOT_ABS)/DBs
REF_CLIB_DIR := $(REF_ROOT_ABS)/CLIBs
REF_TECH_DIR := $(REF_ROOT_ABS)/tech
LVT_NDM_PATH := $(REF_CLIB_DIR)/saed32_lvt.ndm
TECH_FILE_PATH := $(REF_TECH_DIR)/saed32nm_1p9m.tf
TLUPLUS_MAX_PATH := $(REF_TECH_DIR)/saed32nm_1p9m_Cmax.tluplus
MAP_FILE_PATH := $(REF_TECH_DIR)/saed32nm_tf_itf_tluplus.map

.PHONY: help doctor show find-lib link-ref unlink-ref setup syn gui clean clean-all

help:
	@echo "Lab 03 - sintese gradual com constraints"
	@echo
	@echo "Preparacao recomendada:"
	@echo "  1. module load designcompiler/W-2024.09-SP5-4"
	@echo "  2. make find-lib"
	@echo "  3. make link-ref SAED32_SOURCE_REF=/caminho/terminado/em/ref"
	@echo "  4. make doctor"
	@echo "  5. make syn LEVEL=0"
	@echo
	@echo "Biblioteca SAED32:"
	@echo "  O lab espera REF_ROOT=$(REF_ROOT), normalmente ../ref."
	@echo "  O alvo link-ref cria um link simbolico ../ref para a pasta fornecida."
	@echo "  Use: make link-ref SAED32_SOURCE_REF=/caminho/terminado/em/ref"
	@echo "  Para testar outro local sem link: REF_ROOT=/caminho/para/ref."
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
	@echo "  make link-ref"

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
		echo "  Procedimento recomendado:"; \
		echo "    1. make find-lib"; \
		echo "    2. make link-ref SAED32_SOURCE_REF=/caminho/terminado/em/ref"; \
		echo "    3. make doctor"; \
		echo "  Alternativa sem link: make doctor REF_ROOT=/caminho/para/ref"; \
		status=1; \
	fi; \
	if [ -f "$(TARGET_DB_PATH)" ]; then \
		[ -e "$(LVT_NDM_PATH)" ] && echo "OK: NDM encontrado: $(LVT_NDM_PATH)" || echo "AVISO: NDM nao encontrado: $(LVT_NDM_PATH)"; \
		[ -f "$(TECH_FILE_PATH)" ] && echo "OK: technology file encontrado: $(TECH_FILE_PATH)" || echo "AVISO: technology file nao encontrado: $(TECH_FILE_PATH)"; \
		[ -f "$(TLUPLUS_MAX_PATH)" ] && echo "OK: TLUPlus encontrado: $(TLUPLUS_MAX_PATH)" || echo "AVISO: TLUPlus nao encontrado: $(TLUPLUS_MAX_PATH)"; \
		[ -f "$(MAP_FILE_PATH)" ] && echo "OK: map file encontrado: $(MAP_FILE_PATH)" || echo "AVISO: map file nao encontrado: $(MAP_FILE_PATH)"; \
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
	@echo "REF_SOURCE:   $(SAED32_SOURCE_REF)  (usado apenas por make link-ref)"
	@echo "REF_LIB:      $(REF_LIB_ABS)  (legado, opcional)"
	@echo "TARGET_DB:    $(TARGET_DB)"
	@echo "TARGET_PATH:  $(TARGET_DB_PATH)"
	@echo "LVT_NDM:      $(LVT_NDM_PATH)"
	@echo "TECH_FILE:    $(TECH_FILE_PATH)"
	@echo "TLUPLUS_MAX:  $(TLUPLUS_MAX_PATH)"
	@echo "MAP_FILE:     $(MAP_FILE_PATH)"
	@echo "DRIVE_LIB:    $(DRIVE_LIB)"
	@echo "DRIVE_CELL:   $(DRIVE_CELL)"
	@echo "LOAD_CELL:    $(LOAD_CELL)"
	@echo "PHYS_SETUP:   $(ENABLE_PHYSICAL_SETUP)"
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
		echo "  make link-ref SAED32_SOURCE_REF=/caminho/terminado/em/ref"; \
		echo "  make doctor"; \
		echo "  make syn LEVEL=0"; \
	fi; \
	rm -f "$$tmp"

link-ref:
	@echo "--- [LINK-REF] Preparando ../ref ---"; \
	if [ -z "$(SAED32_SOURCE_REF)" ]; then \
		echo "ERRO: informe SAED32_SOURCE_REF."; \
		echo "Use: make link-ref SAED32_SOURCE_REF=/caminho/terminado/em/ref"; \
		exit 1; \
	fi; \
	if [ ! -d "$(SAED32_SOURCE_REF)" ]; then \
		echo "ERRO: SAED32_SOURCE_REF nao existe: $(SAED32_SOURCE_REF)"; \
		echo "Use: make link-ref SAED32_SOURCE_REF=/caminho/terminado/em/ref"; \
		exit 1; \
	fi; \
	if [ ! -f "$(SAED32_SOURCE_REF)/DBs/$(TARGET_DB)" ]; then \
		echo "ERRO: a fonte nao contem DBs/$(TARGET_DB): $(SAED32_SOURCE_REF)"; \
		exit 1; \
	fi; \
	if [ -e "../ref" ] || [ -L "../ref" ]; then \
		echo "ERRO: ../ref ja existe."; \
		echo "Se for um link antigo, remova com: make unlink-ref"; \
		echo "Se for uma pasta real, preserve-a ou remova manualmente com cuidado."; \
		exit 1; \
	fi; \
	ln -s "$(SAED32_SOURCE_REF)" "../ref"; \
	echo "OK: criado link simbolico:"; \
	ls -ld "../ref"; \
	echo "Agora rode: make doctor"

unlink-ref:
	@if [ -L "../ref" ]; then \
		echo "--- [UNLINK-REF] Removendo link simbolico ../ref ---"; \
		rm "../ref"; \
		echo "OK: link removido."; \
	elif [ -e "../ref" ]; then \
		echo "ERRO: ../ref existe, mas nao e link simbolico. Nao vou remover pasta real."; \
		exit 1; \
	else \
		echo "OK: ../ref nao existe."; \
	fi

setup:
	@mkdir -p "$(RUN_DIR)" reports mapped unmapped

# doctor e executado antes da sintese. Se a biblioteca estiver ausente,
# o fluxo para aqui, em vez de abrir o dc_shell para falhar mais adiante.
syn: doctor setup
	@echo "--- [SYN] Rodando Design Compiler para LEVEL=$(LEVEL) ---"
	@echo "Log principal: $(RUN_DIR)/dc_level$(LEVEL).log"
	dc_shell -x "set LAB_LEVEL $(LEVEL); set DESIGN_TOP $(TOP); set DESIGN_WIDTH $(WIDTH); set REF_ROOT_PATH {$(REF_ROOT_ABS)}; set REF_LIB_PATH {$(REF_LIB_ABS)}; set TARGET_DB_NAME {$(TARGET_DB)}; set DRIVE_LIB_NAME {$(DRIVE_LIB)}; set DRIVE_CELL_NAME {$(DRIVE_CELL)}; set LOAD_CELL_NAME {$(LOAD_CELL)}; set ENABLE_PHYSICAL_SETUP {$(ENABLE_PHYSICAL_SETUP)}; source -e -v scripts/run_dc.tcl" | tee "$(RUN_DIR)/dc_level$(LEVEL).log"

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
