# ==============================================================================
# Lab 03 - run_dc.tcl
# ==============================================================================
#
# Este e o script principal de sintese.
#
# Ele e chamado pelo Makefile assim:
#
#   dc_shell -x "set LAB_LEVEL 1; set DESIGN_TOP mini_datapath; ...; source scripts/run_dc.tcl"
#
# Fluxo, inspirado no lab 04 ces_svrtl_2019.03:
#
#   1. carregar setup de biblioteca via scripts/dc_setup.tcl;
#   2. analisar os arquivos SystemVerilog;
#   3. elaborar o top parametrizado;
#   4. fazer link;
#   5. gravar uma versao unmapped;
#   6. aplicar constraints do nivel escolhido;
#   7. rodar compile_ultra;
#   8. gravar netlist mapeada e relatorios.
#
# Leitura mental:
#
#   analyze   = ler codigo fonte
#   elaborate = construir a hierarquia com parametros resolvidos
#   link      = conectar referencias entre modulos e biblioteca
#   compile   = otimizar e mapear para celulas da biblioteca

if {![info exists LAB_LEVEL]} {
  set LAB_LEVEL 0
}

if {![info exists DESIGN_TOP]} {
  set DESIGN_TOP mini_datapath
}

if {![info exists DESIGN_WIDTH]} {
  set DESIGN_WIDTH 8
}

# dc_setup.tcl carrega common_setup.tcl e aplica:
#
#   - search_path;
#   - target_library;
#   - link_library;
#   - setup fisico opcional, quando ENABLE_PHYSICAL_SETUP=1.
#
# A aula recomenda essa separacao: common_setup.tcl guarda variaveis editaveis,
# dc_setup.tcl executa o procedimento reutilizavel.
source scripts/dc_setup.tcl

set REPORT_DIR   "reports"
set MAPPED_DIR   "mapped"
set UNMAPPED_DIR "unmapped"

file mkdir $REPORT_DIR
file mkdir $MAPPED_DIR
file mkdir $UNMAPPED_DIR

puts "INFO Lab03: nivel de constraints = $LAB_LEVEL"
puts "INFO Lab03: top = $DESIGN_TOP"
puts "INFO Lab03: WIDTH = $DESIGN_WIDTH"

# A ordem abaixo e didatica:
#   - regbank e alu sao blocos folha;
#   - mini_datapath instancia os dois.
#
# O DC normalmente consegue resolver mesmo se a ordem nao for perfeita, mas
# manter a ordem ajuda a ler logs e aprender hierarquia.
analyze -format sverilog [list \
  "../rtl/regbank.sv" \
  "../rtl/alu.sv" \
  "../rtl/mini_datapath.sv" \
]

# Elaborar com parametro WIDTH.
#
# Se voce quiser estudar o impacto de largura no timing, rode:
#
#   make syn LEVEL=4 WIDTH=16
#
# A multiplicacao/divisao da ALU ficarao maiores, e os relatorios devem mudar.
elaborate $DESIGN_TOP -param "WIDTH=$DESIGN_WIDTH"

current_design $DESIGN_TOP
link
uniquify

redirect -file "$REPORT_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_check_design_pre.rpt" {
  check_design
}

write_file -format verilog -hierarchy -output "$UNMAPPED_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_unmapped.v"
write_file -format ddc     -hierarchy -output "$UNMAPPED_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_unmapped.ddc"

set CONSTRAINT_FILE "scripts/constraints_level${LAB_LEVEL}.tcl"
if {![file exists $CONSTRAINT_FILE]} {
  puts "ERRO: arquivo de constraints nao encontrado: $CONSTRAINT_FILE"
  exit 1
}

source $CONSTRAINT_FILE

redirect -file "$REPORT_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_check_timing_pre_compile.rpt" {
  check_timing
}

# compile_ultra e o comando de sintese/otimizacao.
#
# No nivel 0, ha pouca orientacao temporal. A ferramenta ainda pode mapear, mas
# nao existe uma meta clara de clock.
#
# Nos niveis seguintes, constraints dizem o que significa "bom o bastante".
compile_ultra

write_file -format verilog -hierarchy -output "$MAPPED_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_mapped.v"
write_file -format ddc     -hierarchy -output "$MAPPED_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_mapped.ddc"

redirect -file "$REPORT_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_qor.rpt" {
  report_qor
}

redirect -file "$REPORT_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_timing.rpt" {
  report_timing -max_paths 10 -delay_type max -input_pins -nets
}

redirect -file "$REPORT_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_area.rpt" {
  report_area -hierarchy
}

redirect -file "$REPORT_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_constraints.rpt" {
  report_constraint -all_violators
}

redirect -file "$REPORT_DIR/${DESIGN_TOP}_level${LAB_LEVEL}_resources.rpt" {
  report_resources -hierarchy
}

puts "INFO Lab03: sintese concluida para LEVEL=$LAB_LEVEL"
puts "INFO Lab03: veja reports/${DESIGN_TOP}_level${LAB_LEVEL}_*.rpt"

exit
