# ==============================================================================
# Lab 02B - primeira automacao de sintese
# ==============================================================================
#
# Este script deve ser estudado somente DEPOIS das duas execucoes manuais do
# roteiro_manual_dc_shell.md. Ele nao introduz framework, funcoes auxiliares,
# deteccao automatica, common_setup.tcl ou dc_setup.tcl. Cada linha corresponde
# diretamente a um comando que ja foi digitado a mao.
#
# Execucao, a partir de ~/curso/02B/synthesis:
#
#   mkdir -p logs
#   dc_shell -f run_minimal.tcl | tee logs/run_minimal.log
#
# Esta versao representa a segunda execucao manual: possui apenas a constraint
# minima de clock. Nao ha input delay, output delay, uncertainty, load, driving
# cell nem informacao fisica.

puts "LAB02B: inicio do run_minimal.tcl"

# Pastas de saida. file mkdir e um comando TCL, executado dentro do dc_shell.
# Ele nao procura caminhos nem escolhe alternativas: apenas cria as tres pastas
# declaradas abaixo quando elas ainda nao existem.
file mkdir unmapped
file mkdir mapped
file mkdir reports

# ----------------------------------------------------------------------------
# 1. Biblioteca logica e caminhos de busca
# ----------------------------------------------------------------------------
#
# O Lab 03 usa 03/ref como arvore de referencia. Para evitar uma segunda copia
# da biblioteca, este laboratorio aponta explicitamente para a mesma pasta:
#
#   ~/curso/03/ref/DBs/saed32lvt_ss0p75v125c.db
#
# Como o dc_shell e aberto em ~/curso/02B/synthesis, o caminho relativo e:
#
#   ../../03/ref/DBs

set_app_var search_path [concat $search_path [list "../rtl" "../../03/ref/DBs"]]
set_app_var target_library [list "saed32lvt_ss0p75v125c.db"]
set_app_var link_library [concat [list "*"] $target_library]

printvar search_path
printvar target_library
printvar link_library

puts "LAB02B: biblioteca logica configurada"

# ----------------------------------------------------------------------------
# 2. Leitura e construcao do design
# ----------------------------------------------------------------------------
#
# analyze valida e traduz o SystemVerilog para a representacao intermediaria.
# elaborate cria uma instancia concreta do top synth_intro.
# current_design seleciona explicitamente esse top para os proximos comandos.
# link resolve as referencias do design contra o que esta em memoria e contra a
# link_library.

analyze -format sverilog [list "../rtl/synth_intro.sv"]
elaborate synth_intro
current_design synth_intro
link

# check_design retorna 1 quando a verificacao estrutural termina com sucesso.
# Se retornar 0, paramos o script para nao compilar um design estruturalmente
# inconsistente. Essa e a unica verificacao de controle usada aqui.
if {[check_design] == 0} {
    error "LAB02B: check_design encontrou problemas; compile interrompido."
}

puts "LAB02B: analyze, elaborate, current_design, link e check_design concluidos"

# O DDC unmapped registra o estado do design antes do mapeamento tecnologico.
# Ele e uma fotografia interna do Design Compiler, nao uma netlist Verilog para
# simulacao externa.
write_file -format ddc -hierarchy \
    -output "unmapped/synth_intro_unmapped.ddc"

puts "LAB02B: DDC unmapped salvo"

# ----------------------------------------------------------------------------
# 3. Unica constraint deste laboratorio
# ----------------------------------------------------------------------------
#
# O periodo de 10 usa a unidade de tempo da biblioteca, normalmente ns neste
# setup. Ele cria uma exigencia para caminhos sequenciais associados a clk.
# Nao gera o clock da simulacao e nao descreve o mundo externo.

create_clock -period 10 [get_ports clk]

redirect -tee -file "reports/clock_minimal.rpt" {
    report_clock
}

redirect -tee -file "reports/check_timing_minimal.rpt" {
    check_timing
}

puts "LAB02B: clock de 10 ns criado e timing pre-compile conferido"

# ----------------------------------------------------------------------------
# 4. Otimizacao e mapeamento
# ----------------------------------------------------------------------------
#
# compile_ultra transforma a logica generica em celulas da target_library e
# tenta satisfazer o clock declarado. Nao usamos -scan, -retime ou -spg.

compile_ultra

redirect -tee -file "reports/area_minimal.rpt" {
    report_area
}

redirect -tee -file "reports/reference_minimal.rpt" {
    report_reference
}

redirect -tee -file "reports/timing_minimal.rpt" {
    report_timing
}

puts "LAB02B: compile_ultra e reports concluidos"

# ----------------------------------------------------------------------------
# 5. Saidas mapeadas
# ----------------------------------------------------------------------------
#
# O Verilog e uma netlist estrutural legivel por outras ferramentas.
# O DDC preserva a representacao interna completa para reabrir no DC.

write_file -format verilog -hierarchy \
    -output "mapped/synth_intro_mapped.v"

write_file -format ddc -hierarchy \
    -output "mapped/synth_intro_mapped.ddc"

puts "LAB02B: netlist Verilog e DDC mapped salvos"
puts "LAB02B: fim do run_minimal.tcl"

exit
