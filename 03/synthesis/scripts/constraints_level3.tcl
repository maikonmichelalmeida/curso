# ==============================================================================
# Nivel 3 - Margens de clock
# ==============================================================================
#
# Agora refinamos o clock.
#
# create_clock diz o periodo ideal. Mas clock fisico nao e perfeito:
#
#   - ha incerteza/jitter/skew;
#   - ha latencia ate o clock chegar aos registradores;
#   - ha tempo de transicao da borda.
#
# Estes comandos ainda sao modelos simplificados, mas aproximam o laboratorio do
# constraint.tcl do lab 04 ces_svrtl_2019.03.

source scripts/constraints_level2.tcl

set CLK_SKEW            0.20
set CLK_INT_LATENCY     0.10
set CLK_SOURCE_LATENCY  0.30
set CLK_TRANSITION      0.02

set_clock_uncertainty -setup $CLK_SKEW           [get_clocks clk]
set_clock_latency     -max   $CLK_INT_LATENCY    [get_clocks clk]
set_clock_latency     -source -max $CLK_SOURCE_LATENCY [get_clocks clk]
set_clock_transition  -max   $CLK_TRANSITION     [get_clocks clk]

puts "INFO Nivel 3: clock uncertainty, latency e transition aplicados."
