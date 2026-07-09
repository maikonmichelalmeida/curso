# ==============================================================================
# Lab 01 - SystemVerilog RTL: mismatch, latch e FSM
# ==============================================================================
#
# Este Makefile e didatico. Ele nao tenta esconder as ferramentas:
# - VCS compila e simula RTL ou netlist gate-level.
# - Verdi abre a waveform FSDB.
# - Design Compiler sintetiza o RTL usando o Tcl comentado em tools/.
#
# Uso basico:
#   make help
#   make sim EX=01 CASE=bad
#   make sim EX=01 CASE=good
#   make synth EX=01 CASE=bad
#   make gate EX=01 CASE=bad

SHELL := /bin/bash

EX   ?= 01
CASE ?= bad
GUI  ?= 0

LAB_ROOT := $(CURDIR)
RUN_DIR  := run/$(EX)_$(CASE)
LOG_DIR  := logs/$(EX)_$(CASE)
RPT_DIR  := rpt/$(EX)_$(CASE)
OUT_DIR  := outputs/$(EX)_$(CASE)

# O default tenta usar a biblioteca SAED que ja aparece no ambiente do professor.
# Se o seu servidor tiver outro caminho, rode:
#   make doctor SAED_REF=/caminho/para/ref
SAED_REF ?= $(HOME)/RTL_LAB2/estudo_ambiente2/PROJECT_ENVIROMENT/module_CPU_pdk_SAED/ref
SAED_DB  ?= $(SAED_REF)/DBs/saed32lvt_ss0p75v125c.db
SAED_VERILOG ?= $(SAED_REF)/verilog/saed32nm_lvt.v

VCS_FLAGS := -full64 -sverilog -timescale=1ns/1ps -debug_access+all -kdb +vcs+fsdbon
DC_TOOL   ?= dc_shell

# ------------------------------------------------------------------------------
# Tabela dos exemplos
# ------------------------------------------------------------------------------
SRC_01_bad  := rtl/01_sensitivity_bad.sv
SRC_01_good := rtl/01_sensitivity_good.sv
TB_01       := tb/tb_01_sensitivity.sv
TOP_01      := tb_01_sensitivity
DESIGN_01   := sensitivity_dut

SRC_02_bad  := rtl/02_latch_bad.sv
SRC_02_good := rtl/02_latch_good.sv
TB_02       := tb/tb_02_latch.sv
TOP_02      := tb_02_latch
DESIGN_02   := latch_dut

SRC_03_bad  := rtl/03_fsm_bad.sv
SRC_03_good := rtl/03_fsm_good.sv
TB_03       := tb/tb_03_fsm.sv
TOP_03      := tb_03_fsm
DESIGN_03   := fsm_dut

SRC    := $(SRC_$(EX)_$(CASE))
TB     := $(TB_$(EX))
TOP    := $(TOP_$(EX))
DESIGN := $(DESIGN_$(EX))

NETLIST := $(OUT_DIR)/$(DESIGN)_mapped.v
SDF     := $(OUT_DIR)/$(DESIGN)_delays.sdf

.PHONY: help list doctor check setup sim waves synth gate clean clean-all show

help:
	@echo "Lab 01 - SystemVerilog RTL: mismatch, latch e FSM"
	@echo
	@echo "Comandos principais:"
	@echo "  make list                         Lista exemplos"
	@echo "  make doctor                       Checa ferramentas e biblioteca"
	@echo "  make sim EX=01 CASE=bad           Simula RTL ruim"
	@echo "  make sim EX=01 CASE=good          Simula RTL correto"
	@echo "  make waves EX=01 CASE=bad         Abre waveform do ultimo sim"
	@echo "  make synth EX=01 CASE=bad         Sintetiza a variante"
	@echo "  make gate EX=01 CASE=bad          Simula netlist gerada"
	@echo "  make show EX=01 CASE=bad          Mostra configuracao escolhida"
	@echo "  make clean-all                    Limpa arquivos gerados"
	@echo
	@echo "Exemplos:"
	@echo "  EX=01  sensitivity list incompleta vs always_comb"
	@echo "  EX=02  latch nao intencional vs atribuicao default"
	@echo "  EX=03  FSM fragil vs enum + always_ff + always_comb"
	@echo
	@echo "Roteiro:"
	@echo "  leia docs/guia_lab.md"

list:
	@echo "EX=01 CASE=bad|good  sensitivity list incompleta"
	@echo "EX=02 CASE=bad|good  latch nao intencional"
	@echo "EX=03 CASE=bad|good  FSM fragil/correta"

doctor:
	@echo "Ferramentas:"
	@command -v vcs >/dev/null 2>&1 && echo "  VCS: encontrado" || echo "  VCS: nao encontrado"
	@command -v verdi >/dev/null 2>&1 && echo "  Verdi: encontrado" || echo "  Verdi: nao encontrado"
	@command -v $(DC_TOOL) >/dev/null 2>&1 && echo "  $(DC_TOOL): encontrado" || echo "  $(DC_TOOL): nao encontrado"
	@echo
	@echo "Biblioteca:"
	@if [ -f "$(SAED_DB)" ]; then echo "  DB: $(SAED_DB)"; else echo "  DB nao encontrada: $(SAED_DB)"; fi
	@if [ -f "$(SAED_VERILOG)" ]; then echo "  Verilog: $(SAED_VERILOG)"; else echo "  Verilog nao encontrado: $(SAED_VERILOG)"; fi

check:
	@if [ -z "$(SRC)" ] || [ ! -f "$(SRC)" ]; then echo "ERRO: SRC invalido para EX=$(EX) CASE=$(CASE): $(SRC)"; exit 1; fi
	@if [ -z "$(TB)" ] || [ ! -f "$(TB)" ]; then echo "ERRO: TB invalido para EX=$(EX): $(TB)"; exit 1; fi
	@if [ -z "$(TOP)" ]; then echo "ERRO: TOP invalido para EX=$(EX)"; exit 1; fi
	@if [ -z "$(DESIGN)" ]; then echo "ERRO: DESIGN invalido para EX=$(EX)"; exit 1; fi

setup: check
	@mkdir -p $(RUN_DIR) $(LOG_DIR) $(RPT_DIR) $(OUT_DIR)

show: check
	@echo "EX:            $(EX)"
	@echo "CASE:          $(CASE)"
	@echo "SRC:           $(SRC)"
	@echo "TB:            $(TB)"
	@echo "TOP:           $(TOP)"
	@echo "DESIGN:        $(DESIGN)"
	@echo "RUN_DIR:       $(RUN_DIR)"
	@echo "SAED_REF:      $(SAED_REF)"
	@echo "DC_TOOL:       $(DC_TOOL)"

sim: setup
	@echo "--- [SIM RTL] EX=$(EX) CASE=$(CASE) ---"
	cd $(RUN_DIR) && vcs $(VCS_FLAGS) ../../$(SRC) ../../$(TB) -top $(TOP) -o simv -l ../../$(LOG_DIR)/vcs_compile.log
	cd $(RUN_DIR) && ./simv -l ../../$(LOG_DIR)/vcs_run.log
	@echo "Veja o log:      $(LOG_DIR)/vcs_run.log"
	@echo "Veja a waveform: $(RUN_DIR)/wave.fsdb"

waves: check
	@if [ ! -f "$(RUN_DIR)/wave.fsdb" ]; then echo "ERRO: rode make sim EX=$(EX) CASE=$(CASE) antes."; exit 1; fi
	cd $(RUN_DIR) && verdi -ssf wave.fsdb &

synth: setup
	@echo "--- [SYNTH] EX=$(EX) CASE=$(CASE) DESIGN=$(DESIGN) ---"
	@if [ ! -f "$(SAED_DB)" ]; then echo "ERRO: biblioteca DB nao encontrada: $(SAED_DB)"; exit 1; fi
	cd $(RUN_DIR) && set -o pipefail && \
		DESIGN="$(DESIGN)" \
		RTL_SRC="../../$(SRC)" \
		SDC_FILE="../../constraints/basic.sdc" \
		SAED_DB="$(SAED_DB)" \
		RPT_DIR="../../$(RPT_DIR)" \
		OUT_DIR="../../$(OUT_DIR)" \
		$(DC_TOOL) -64bit -f ../../tools/synth_dc.tcl | tee ../../$(LOG_DIR)/dc_synth.log
	@echo "Relatorios: $(RPT_DIR)"
	@echo "Outputs:    $(OUT_DIR)"

gate: setup
	@echo "--- [SIM GATE] EX=$(EX) CASE=$(CASE) ---"
	@if [ ! -f "$(NETLIST)" ]; then echo "ERRO: netlist nao encontrada: $(NETLIST). Rode make synth primeiro."; exit 1; fi
	@if [ ! -f "$(SAED_VERILOG)" ]; then echo "ERRO: biblioteca Verilog nao encontrada: $(SAED_VERILOG)"; exit 1; fi
	cd $(RUN_DIR) && vcs $(VCS_FLAGS) -v "$(SAED_VERILOG)" ../../$(NETLIST) ../../$(TB) -top $(TOP) -o simv_gate -l ../../$(LOG_DIR)/gate_compile.log
	cd $(RUN_DIR) && ./simv_gate -l ../../$(LOG_DIR)/gate_run.log
	@echo "Compare:"
	@echo "  RTL log:  $(LOG_DIR)/vcs_run.log"
	@echo "  Gate log: $(LOG_DIR)/gate_run.log"

clean:
	@rm -rf $(RUN_DIR) $(LOG_DIR) $(RPT_DIR) $(OUT_DIR)

clean-all:
	@rm -rf run logs rpt outputs
