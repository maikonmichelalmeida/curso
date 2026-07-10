# ==============================================================================
# Nivel 5 - Mesmo modelo do nivel 4, com foco em leitura de reports
# ==============================================================================
#
# Este nivel nao adiciona uma constraint nova forte. Ele existe para voce rodar
# uma sintese "completa o bastante" e estudar os reports gerados pelo run_dc.tcl:
#
#   report_qor
#   report_timing
#   report_area
#   report_constraint -all_violators
#   report_resources
#
# Por que separar nivel 5?
#
#   Para criar um ponto de parada didatico. Ate aqui voce tem clock, I/O delays,
#   margens de clock e modelo eletrico simples. Agora o exercicio e ler.
#
# Perguntas para responder olhando os reports:
#
#   1. Qual e o pior caminho?
#   2. Ele passa pela multiplicacao ou divisao?
#   3. Ha violacao de setup?
#   4. A area maior esta na ALU ou nos registradores?
#   5. O design tem constraints ausentes?

source scripts/constraints_level4.tcl

puts "INFO Nivel 5: use este nivel como referencia principal para leitura de reports."
