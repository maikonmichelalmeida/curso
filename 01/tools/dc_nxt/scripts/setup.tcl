# ==============================================================================
# Lab 01 - Setup do DC_NXT
# ==============================================================================
#
# Este arquivo responde: "onde estao as coisas?"
# Ele nao sintetiza. Ele apenas define nomes, caminhos e bibliotecas.

# Nome do modulo top que sera sintetizado.
set DESIGN_NAME "lab01_top"

# O DC_NXT sera executado a partir de tools/dc_nxt/run.
# Portanto, ../../../ volta para a raiz do Lab 01.
set BLOCK_ROOT "../../../"

set RTL_FILELIST "${BLOCK_ROOT}/verif/filelist_rtl.f"
set SDC_FILE     "${BLOCK_ROOT}/constraints/constraints.sdc"
set REPORTS_PATH "../rpt"
set OUTPUTS_PATH "../outputs"

# A raiz da biblioteca SAED vem do Makefile por variavel de ambiente.
# Exemplo:
#   make synth SAED_REF=/home/ciexpert/.../ref
if {![info exists ::env(SAED_REF)] || $::env(SAED_REF) eq ""} {
    puts "ERRO: variavel SAED_REF nao foi definida."
    puts "Use: make synth SAED_REF=/caminho/para/ref"
    exit 1
}

set SAED_REF $::env(SAED_REF)

# Subpastas esperadas no ref do ambiente do professor.
set DB_PATH   "${SAED_REF}/DBs"
set CLIB_PATH "${SAED_REF}/CLIBs"
set TECH_PATH "${SAED_REF}/tech"

# Biblioteca logica. O DC_NXT escolhe celulas desta biblioteca para mapear o RTL.
set TARGET_LIBRARY_FILES [list "${DB_PATH}/saed32lvt_ss0p75v125c.db"]

# Bibliotecas fisicas/topograficas. Elas sao usadas quando o fluxo roda em modo
# topographical (-topo), como no ambiente do professor.
set NDM_DESIGN_LIB    "LAB01.dlib"
set NDM_REFERENCE_LIBS [list "${CLIB_PATH}/saed32_lvt.ndm"]
set TECH_FILE          "${TECH_PATH}/saed32nm_1p9m.tf"
set TLUPLUS_MAX_FILE   "${TECH_PATH}/saed32nm_1p9m_Cmax.tluplus"
set MAP_FILE           "${TECH_PATH}/saed32nm_tf_itf_tluplus.map"

# search_path diz onde a ferramenta procura arquivos referenciados pelo nome.
set_app_var search_path [concat \
    [list "." $BLOCK_ROOT "${BLOCK_ROOT}/rtl" "${BLOCK_ROOT}/verif"] \
    [list $DB_PATH $CLIB_PATH $TECH_PATH] \
]

set_app_var target_library $TARGET_LIBRARY_FILES
set_app_var link_library   [concat "*" $target_library]

# Biblioteca WORK recebe os arquivos analisados pelo comando analyze.
define_design_lib WORK -path ./work

# Conferencia explicita dos arquivos de tecnologia. Se algum deles nao existir,
# a mensagem de erro aponta exatamente o que precisa ser corrigido em SAED_REF.
foreach required_file [concat $TARGET_LIBRARY_FILES $NDM_REFERENCE_LIBS [list $TECH_FILE $TLUPLUS_MAX_FILE $MAP_FILE]] {
    if {![file exists $required_file]} {
        puts "ERRO: arquivo de biblioteca/tecnologia nao encontrado:"
        puts "      $required_file"
        puts "Verifique SAED_REF: $SAED_REF"
        exit 1
    }
}

# Esta parte e a diferenca entre uma sintese puramente logica e um fluxo DC_NXT
# topografico. O create_lib abre/cria a biblioteca fisica de trabalho e conecta
# a tecnologia SAED. E exatamente o tipo de configuracao que aparece nos labs.
if {![file isdirectory $NDM_DESIGN_LIB]} {
    puts "Criando NDM design library: $NDM_DESIGN_LIB"
    create_lib \
        -technology $TECH_FILE \
        -ref_libs   $NDM_REFERENCE_LIBS \
        $NDM_DESIGN_LIB
} else {
    puts "Abrindo NDM design library existente: $NDM_DESIGN_LIB"
    open_lib $NDM_DESIGN_LIB
}

set_tlu_plus_files \
    -max_tluplus  $TLUPLUS_MAX_FILE \
    -tech2itf_map $MAP_FILE

puts "=================================================================="
puts "Lab 01 DC_NXT setup"
puts "DESIGN_NAME:       $DESIGN_NAME"
puts "RTL_FILELIST:      $RTL_FILELIST"
puts "SDC_FILE:          $SDC_FILE"
puts "SAED_REF:          $SAED_REF"
puts "search_path:       $search_path"
puts "target_library:    $target_library"
puts "link_library:      $link_library"
puts "NDM_DESIGN_LIB:    $NDM_DESIGN_LIB"
puts "NDM_REFERENCE_LIBS:$NDM_REFERENCE_LIBS"
puts "=================================================================="
