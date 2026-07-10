# ==============================================================================
# Nivel 1 - Clock basico
# ==============================================================================
#
# Primeira constraint real: create_clock.
#
# O mini_datapath tem registradores. Registradores usam clock. A ferramenta
# precisa saber qual e o periodo desse clock para avaliar o caminho:
#
#   reg_a/reg_b -> ALU -> result_reg
#
# Se CLK_PERIOD = 10.0, estamos dizendo:
#
#   "Considere que ha uma borda de clock a cada 10 ns."
#
# Em termos simples, a logica entre registradores precisa caber nesse intervalo,
# descontando tempos internos de registrador e margens que entrao nos proximos
# niveis.

reset_design

set CLK_PERIOD 10.0

create_clock -name clk -period $CLK_PERIOD [get_ports clk]

# rst e reset assincrono. Neste laboratorio, nao queremos que o DC tente tratar
# rst como um caminho de dados comum. Por isso declaramos false path a partir
# dele. Em projetos reais, reset merece estrategia propria, mas este e um bom
# primeiro passo didatico.
set_false_path -from [get_ports rst]

puts "INFO Nivel 1: create_clock aplicado com periodo de $CLK_PERIOD ns."
puts "INFO Nivel 1: rst marcado como false path."
