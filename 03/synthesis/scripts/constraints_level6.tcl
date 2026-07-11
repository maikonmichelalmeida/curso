# ==============================================================================
# Nivel 6 - Experimento com clock apertado
# ==============================================================================
#
# Este nivel e propositalmente mais agressivo.
#
# Em vez de 10 ns, usamos 4 ns. A intencao e aumentar a chance de aparecer uma
# violacao de timing ou uma otimizacao mais pesada.
#
# Isso ensina uma licao central:
#
#   Constraint nao e decoracao. Quando voce aperta o clock, a ferramenta precisa
#   trabalhar mais. Se o datapath for pesado demais, ela pode nao conseguir.
#
# Este arquivo repete as constraints em vez de simplesmente dar source no nivel 4
# porque queremos trocar o clock de maneira limpa e legivel.

reset_design

set CLK_PERIOD          4.0
set INPUT_DELAY_MAX     0.8
set OUTPUT_DELAY_MAX    0.8
set CLK_SKEW            0.20
set CLK_INT_LATENCY     0.10
set CLK_SOURCE_LATENCY  0.30
set CLK_TRANSITION      0.02

create_clock -name clk -period $CLK_PERIOD [get_ports clk]
set_false_path -from [get_ports rst]

set ALL_INPUTS_EXCEPT_CLOCK_RESET [remove_from_collection [all_inputs] [get_ports {clk rst}]]

set_input_delay  -max $INPUT_DELAY_MAX  -clock clk $ALL_INPUTS_EXCEPT_CLOCK_RESET
set_output_delay -max $OUTPUT_DELAY_MAX -clock clk [all_outputs]

set_clock_uncertainty -setup $CLK_SKEW           [get_clocks clk]
set_clock_latency     -max   $CLK_INT_LATENCY    [get_clocks clk]
set_clock_latency     -source -max $CLK_SOURCE_LATENCY [get_clocks clk]
set_clock_transition  -max   $CLK_TRANSITION     [get_clocks clk]

if {![info exists LAB03_DRIVE_LIB_NAME]} {
  set LAB03_DRIVE_LIB_NAME saed32lvt_ss0p75v125c
}

if {![info exists LAB03_DRIVE_CELL_NAME]} {
  set LAB03_DRIVE_CELL_NAME NBUFFX2_LVT
}

if {![info exists LAB03_LOAD_CELL_NAME]} {
  set LAB03_LOAD_CELL_NAME NBUFFX16_LVT
}

set LIB_NAME $LAB03_DRIVE_LIB_NAME
set DRIVE_CELL $LAB03_DRIVE_CELL_NAME
set LOAD_CELL  $LAB03_LOAD_CELL_NAME
set LOAD_CELL_INPUT_PIN "$LIB_NAME/$LOAD_CELL/A"

suppress_message UID-401
set_driving_cell -max -library $LIB_NAME -lib_cell $DRIVE_CELL $ALL_INPUTS_EXCEPT_CLOCK_RESET
set MAX_INPUT_LOAD [expr {[load_of $LOAD_CELL_INPUT_PIN] * 10}]
set_max_capacitance $MAX_INPUT_LOAD $ALL_INPUTS_EXCEPT_CLOCK_RESET
set_load -max [expr {[load_of $LOAD_CELL_INPUT_PIN] * 3}] [all_outputs]

puts "INFO Nivel 6: clock apertado para $CLK_PERIOD ns."
puts "INFO Nivel 6: este nivel e para observar pressao de timing."
