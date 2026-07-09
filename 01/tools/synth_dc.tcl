# ==============================================================================
# Lab 01 - Script de sintese comentado
# ==============================================================================
#
# Este Tcl e parte da aula. Leia no VS Code antes de rodar.
#
# Ele faz o fluxo minimo de sintese logica:
#   1. recebe variaveis vindas do Makefile;
#   2. configura biblioteca tecnologica;
#   3. le o RTL SystemVerilog;
#   4. elabora o design;
#   5. aplica constraints SDC;
#   6. roda compile_ultra;
#   7. gera relatorios e netlist.
#
# O ponto didatico: para cada exemplo ruim/correto, o mesmo script e usado.
# Assim voce observa como pequenas mudancas no RTL mudam o comportamento da
# simulacao, da sintese, dos warnings e da netlist.

proc require_env {name} {
    if {![info exists ::env($name)] || $::env($name) eq ""} {
        puts "ERROR: environment variable $name is not defined."
        exit 1
    }
    return $::env($name)
}

# ------------------------------------------------------------------------------
# 1. Variaveis vindas do Makefile
# ------------------------------------------------------------------------------
set DESIGN_NAME [require_env DESIGN]
set RTL_SRC     [require_env RTL_SRC]
set SDC_FILE    [require_env SDC_FILE]
set SAED_DB     [require_env SAED_DB]
set RPT_DIR     [require_env RPT_DIR]
set OUT_DIR     [require_env OUT_DIR]

puts "============================================================"
puts "Lab 01 synthesis"
puts "DESIGN_NAME = $DESIGN_NAME"
puts "RTL_SRC     = $RTL_SRC"
puts "SDC_FILE    = $SDC_FILE"
puts "SAED_DB     = $SAED_DB"
puts "RPT_DIR     = $RPT_DIR"
puts "OUT_DIR     = $OUT_DIR"
puts "============================================================"

foreach dir [list $RPT_DIR $OUT_DIR] {
    if {![file exists $dir]} {
        file mkdir $dir
    }
}

# ------------------------------------------------------------------------------
# 2. Biblioteca tecnologica
# ------------------------------------------------------------------------------
# target_library: celulas que o Design Compiler pode usar para mapear o circuito.
# link_library: bibliotecas usadas para resolver referencias.
#
# No ambiente do professor, o caminho padrao aponta para SAED32 LVT.
# Se seu servidor tiver outro caminho, altere SAED_REF no Makefile ou na chamada.
if {![file exists $SAED_DB]} {
    puts "ERROR: SAED DB not found: $SAED_DB"
    exit 1
}

set_app_var target_library [list $SAED_DB]
set_app_var link_library   [concat "*" $target_library]

# define_design_lib cria a biblioteca WORK onde o DC guarda o RTL analisado.
define_design_lib WORK -path ./work

# ------------------------------------------------------------------------------
# 3. Leitura do RTL
# ------------------------------------------------------------------------------
# analyze compila o SystemVerilog para a biblioteca WORK.
# elaborate escolhe o modulo top e constrói a hierarquia.
if {![file exists $RTL_SRC]} {
    puts "ERROR: RTL source not found: $RTL_SRC"
    exit 1
}

analyze -format sverilog $RTL_SRC
elaborate $DESIGN_NAME
current_design $DESIGN_NAME

# link conecta o design a biblioteca tecnologica.
link

# check_design antes da sintese ajuda a ver problemas estruturais cedo.
check_design > ${RPT_DIR}/${DESIGN_NAME}_check_design_pre.rpt

# Salva uma versao ainda nao mapeada, util para estudar o que o DC entendeu.
write_file -format verilog -hierarchy -output ${OUT_DIR}/${DESIGN_NAME}_unmapped.v
write_file -format ddc     -hierarchy -output ${OUT_DIR}/${DESIGN_NAME}_unmapped.ddc

# ------------------------------------------------------------------------------
# 4. Constraints
# ------------------------------------------------------------------------------
# O SDC diz para a ferramenta qual e o contexto temporal/fisico do bloco.
# Mesmo exemplos combinacionais pequenos usam um clock no SDC porque estamos
# treinando o formato que sera usado nos blocos maiores.
if {![file exists $SDC_FILE]} {
    puts "ERROR: SDC file not found: $SDC_FILE"
    exit 1
}

source -echo -verbose $SDC_FILE
check_timing > ${RPT_DIR}/${DESIGN_NAME}_check_timing_pre.rpt

# ------------------------------------------------------------------------------
# 5. Sintese
# ------------------------------------------------------------------------------
# compile_ultra mapeia o RTL para portas/celulas da biblioteca.
# Nos exemplos ruins, procure warnings sobre latch, sensibilidade ou logica
# inferida de modo diferente do que a simulacao RTL sugeriu.
compile_ultra

# ------------------------------------------------------------------------------
# 6. Relatorios
# ------------------------------------------------------------------------------
report_area -hierarchy           > ${RPT_DIR}/${DESIGN_NAME}_area.rpt
report_timing -max_paths 10      > ${RPT_DIR}/${DESIGN_NAME}_timing.rpt
report_power                     > ${RPT_DIR}/${DESIGN_NAME}_power.rpt
report_qor                       > ${RPT_DIR}/${DESIGN_NAME}_qor.rpt
report_constraint -all_violators > ${RPT_DIR}/${DESIGN_NAME}_constraints.rpt
check_design                     > ${RPT_DIR}/${DESIGN_NAME}_check_design_post.rpt

# ------------------------------------------------------------------------------
# 7. Artefatos para estudo e gate-level simulation
# ------------------------------------------------------------------------------
change_names -rules verilog -hierarchy

write_file -format verilog -hierarchy -output ${OUT_DIR}/${DESIGN_NAME}_mapped.v
write_file -format ddc     -hierarchy -output ${OUT_DIR}/${DESIGN_NAME}_mapped.ddc
write_sdc -nosplit                    ${OUT_DIR}/${DESIGN_NAME}_final.sdc
write_sdf                             ${OUT_DIR}/${DESIGN_NAME}_delays.sdf

puts "============================================================"
puts "Synthesis finished."
puts "Read reports in: $RPT_DIR"
puts "Read outputs in: $OUT_DIR"
puts "============================================================"

exit
