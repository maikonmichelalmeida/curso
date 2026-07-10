# ==============================================================================
# Nivel 0 - Sem constraints reais
# ==============================================================================
#
# Este nivel existe para comparacao.
#
# Aqui NAO criamos clock, NAO informamos atraso de entrada, NAO informamos atraso
# de saida, NAO informamos carga e NAO informamos celula que dirige as entradas.
#
# Por que isso e util?
#
#   Porque voce vera que a ferramenta consegue ler, elaborar e mapear alguma
#   coisa, mas os relatorios de timing nao representam um objetivo fisico real.
#
# A pergunta do nivel 0 e:
#
#   "O fluxo basico roda?"
#
# Ainda nao e:
#
#   "O circuito fecha timing?"

reset_design

puts "INFO Nivel 0: sem create_clock e sem I/O constraints."
puts "INFO Nivel 0: use este resultado apenas como ponto de partida."
