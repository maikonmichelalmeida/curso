# ==============================================================================
# Lab 01 - Constraints SDC basicas
# ==============================================================================
#
# SDC significa Synopsys Design Constraints.
# O RTL diz qual circuito queremos. O SDC diz em qual contexto esse circuito
# precisa funcionar: clock, atrasos de entrada, atrasos de saida e cargas.

# Boa pratica: remove constraints antigas antes de aplicar novas.
reset_design

# ------------------------------------------------------------------------------
# 1. Clock principal
# ------------------------------------------------------------------------------
# O design tem um pino chamado clk. Aqui dizemos que esse pino recebe um clock
# chamado core_clk com periodo de 10 ns.
#
# Periodo de 10 ns equivale a 100 MHz.
create_clock -name core_clk -period 10.000 [get_ports clk]

# Incerteza modela margem para jitter, skew e imprecisoes antes do layout final.
set_clock_uncertainty 0.200 [get_clocks core_clk]

# Transicao do clock, tambem chamada de slew. A ferramenta usa isso no calculo
# de timing.
set_clock_transition 0.100 [get_clocks core_clk]

# ------------------------------------------------------------------------------
# 2. Entradas
# ------------------------------------------------------------------------------
# Entradas, exceto o proprio clock, nao chegam magicamente no tempo zero.
# Modelamos que o circuito externo demora 2 ns para entregar dados apos a borda.
set ALL_INPUTS_EXCEPT_CLK [remove_from_collection [all_inputs] [get_ports clk]]
set_input_delay -clock core_clk 2.000 $ALL_INPUTS_EXCEPT_CLK

# Uma aproximacao simples de celula dirigindo as entradas. Em labs maiores, isso
# costuma vir de uma biblioteca real ou de um modelo mais cuidadoso.
set_driving_cell -lib_cell INVX1_LVT $ALL_INPUTS_EXCEPT_CLK

# ------------------------------------------------------------------------------
# 3. Saidas
# ------------------------------------------------------------------------------
# O circuito que recebe nossas saidas tambem precisa de tempo para amostrar.
# Aqui reservamos 2 ns para esse mundo externo.
set_output_delay -clock core_clk 2.000 [all_outputs]

# Carga capacitiva simples nas saidas. Sem carga, a ferramenta pode otimizar com
# uma visao irrealista do mundo externo.
set_load 0.050 [all_outputs]

# ------------------------------------------------------------------------------
# 4. Reset
# ------------------------------------------------------------------------------
# rst_n e assincrono neste exemplo. Ele nao e um caminho de dados normal que
# precisa fechar timing como os caminhos sincronizados por clock.
set_false_path -from [get_ports rst_n]

# ------------------------------------------------------------------------------
# 5. Relatorio rapido no log
# ------------------------------------------------------------------------------
report_clocks
