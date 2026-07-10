# ==============================================================================
# Nivel 2 - Clock + atrasos de entrada e saida
# ==============================================================================
#
# Agora adicionamos uma ideia fisica importante:
#
#   O nosso bloco nao vive sozinho.
#
# Um circuito externo entrega sinais para as entradas do mini_datapath. Esses
# sinais nao chegam exatamente na borda ideal do clock. Eles chegam depois de
# algum atraso externo.
#
# De forma parecida, as saidas do mini_datapath serao capturadas por algo fora
# dele. Esse "algo fora" tambem precisa de tempo para receber sinais estaveis.
#
# set_input_delay:
#   reserva parte do periodo para o circuito que vem antes do nosso bloco.
#
# set_output_delay:
#   reserva parte do periodo para o circuito que vem depois do nosso bloco.

source scripts/constraints_level1.tcl

set INPUT_DELAY_MAX  2.0
set OUTPUT_DELAY_MAX 2.0

set ALL_INPUTS_EXCEPT_CLOCK_RESET [remove_from_collection [all_inputs] [get_ports {clk rst}]]

set_input_delay  -max $INPUT_DELAY_MAX  -clock clk $ALL_INPUTS_EXCEPT_CLOCK_RESET
set_output_delay -max $OUTPUT_DELAY_MAX -clock clk [all_outputs]

puts "INFO Nivel 2: input_delay max = $INPUT_DELAY_MAX ns."
puts "INFO Nivel 2: output_delay max = $OUTPUT_DELAY_MAX ns."
