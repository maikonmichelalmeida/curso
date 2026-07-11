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
  set LAB03_DRIVE_CELL_NAME INVX0_LVT
}

set LIB_NAME $LAB03_DRIVE_LIB_NAME
set CELL     $LAB03_DRIVE_CELL_NAME

set LOAD_CELL            "$LIB_NAME/$CELL"
set LOAD_CELL_INPUT_PIN  "$LOAD_CELL/A"

set ALL_INPUTS_EXCEPT_CLOCK_RESET [remove_from_collection [all_inputs] [get_ports {clk rst}]]

suppress_message UID-401

set_driving_cell -library $LIB_NAME -lib_cell $CELL $ALL_INPUTS_EXCEPT_CLOCK_RESET

set MAX_INPUT_LOAD [expr {[load_of $LOAD_CELL_INPUT_PIN] * 10}]
set_max_capacitance $MAX_INPUT_LOAD $ALL_INPUTS_EXCEPT_CLOCK_RESET

set_load [expr {[load_of $LOAD_CELL_INPUT_PIN] * 3}] [all_outputs]

puts "INFO Nivel 4: driving_cell, max_capacitance e output load aplicados."
