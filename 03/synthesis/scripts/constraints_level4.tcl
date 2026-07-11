# ==============================================================================
# Nivel 4 - Modelo eletrico simples de entradas e saidas
# ==============================================================================
#
# Agora informamos:
#
#   - que tipo de celula dirige as entradas;
#   - qual carga as saidas precisam dirigir;
#   - uma capacitancia maxima aceitavel nas entradas.
#
# Isto nao e layout ainda. E um modelo simples para a sintese nao otimizar no
# vazio. Sem carga de saida, por exemplo, a ferramenta pode subestimar o esforco
# necessario para dirigir o proximo bloco.

source scripts/constraints_level3.tcl

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

set ALL_INPUTS_EXCEPT_CLOCK_RESET [remove_from_collection [all_inputs] [get_ports {clk rst}]]

suppress_message UID-401

set_driving_cell -max -library $LIB_NAME -lib_cell $DRIVE_CELL $ALL_INPUTS_EXCEPT_CLOCK_RESET

set MAX_INPUT_LOAD [expr {[load_of $LOAD_CELL_INPUT_PIN] * 10}]
set_max_capacitance $MAX_INPUT_LOAD $ALL_INPUTS_EXCEPT_CLOCK_RESET

set_load -max [expr {[load_of $LOAD_CELL_INPUT_PIN] * 3}] [all_outputs]

puts "INFO Nivel 4: driving_cell=$LIB_NAME/$DRIVE_CELL."
puts "INFO Nivel 4: load_of usa $LOAD_CELL_INPUT_PIN como referencia."
puts "INFO Nivel 4: max_capacitance e output load aplicados."
