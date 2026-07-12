# ==============================================================================
# Lab 03 - dc_setup.tcl
# ==============================================================================
#
# Este arquivo e a parte reutilizavel do setup, seguindo a organizacao mostrada
# na aula "Design Setup for Physical Synthesis".
#
# Ele:
#
#   1. carrega common_setup.tcl;
#   2. acrescenta DBs/CLIBs/tech ao search_path sem apagar o search_path padrao;
#   3. configura target_library e link_library;
#   4. opcionalmente prepara a design library fisica com create_lib/open_lib.
#
# Para os primeiros niveis do Lab 03, ENABLE_PHYSICAL_SETUP fica 0. Assim voce
# aprende primeiro sintese logica e constraints. Quando for estudar a parte
# fisica/topographical, rode com ENABLE_PHYSICAL_SETUP=1.
#
# Importante para ler reports:
#
#   ENABLE_PHYSICAL_SETUP=0  -> fluxo logico/WLM; usa .db e DesignWare.
#   ENABLE_PHYSICAL_SETUP=1  -> prepara NDM, technology file, TLUPlus e map.
#
# Portanto, se PHYS_SETUP=0 aparecer no Makefile, os arquivos .ndm/.tf/.tluplus
# podem estar presentes e conferidos pelo doctor, mas nao entram na sintese.

source scripts/common_setup.tcl

# ------------------------------------------------------------------------------
# Bibliotecas logicas
# ------------------------------------------------------------------------------

set_app_var search_path [concat $search_path $ADDL_SEARCH_PATH]
set_app_var target_library $TARGET_LIBS

# O "*" permite resolver referencias que ja estao carregadas em memoria.
# dw_foundation.sldb da acesso a componentes DesignWare usados por operadores
# como multiplicacao/divisao quando a ferramenta decidir usar esses recursos.
set_app_var synthetic_library [list "dw_foundation.sldb"]
set_app_var link_library [concat [list "*"] $target_library $ADDL_LINK_LIBS $synthetic_library]

puts "INFO dc_setup: search_path recebeu ADDL_SEARCH_PATH."
puts "INFO dc_setup: target_library=$target_library"
puts "INFO dc_setup: link_library=$link_library"

# ------------------------------------------------------------------------------
# Bibliotecas fisicas, technology file e TLUPlus
# ------------------------------------------------------------------------------
#
# A aula mostra que create_lib/open_lib e set_tlu_plus_files devem acontecer
# antes de ler o RTL em fluxo fisico. Mantemos esse bloco opcional para nao
# misturar o primeiro estudo de constraints com physical synthesis.

if {$ENABLE_PHYSICAL_SETUP} {
  puts "INFO dc_setup: ENABLE_PHYSICAL_SETUP=1; preparando design library fisica."

  foreach required_file [concat $NDM_REFERENCE_LIBS [list $TECH_FILE $TLUPLUS_MAX_FILE $MAP_FILE]] {
    if {![file exists $required_file]} {
      puts "ERRO dc_setup: arquivo fisico nao encontrado: $required_file"
      exit 1
    }
  }

  if {[llength [info commands create_lib]] == 0} {
    puts "ERRO dc_setup: comando create_lib nao esta disponivel nesta sessao."
    puts "ERRO dc_setup: use DC NXT/topographical para estudar o setup fisico."
    exit 1
  }

  if {![file isdirectory $NDM_DESIGN_LIB]} {
    create_lib \
      -ref_libs   $NDM_REFERENCE_LIBS \
      -technology $TECH_FILE \
      $NDM_DESIGN_LIB
  } else {
    open_lib $NDM_DESIGN_LIB
  }

  check_library

  set_tlu_plus_files \
    -max_tluplus  $TLUPLUS_MAX_FILE \
    -tech2itf_map $MAP_FILE

  check_tlu_plus_files
} else {
  puts "INFO dc_setup: setup fisico opcional desligado (ENABLE_PHYSICAL_SETUP=0)."
}
