# ==============================================================================
# Lab 03 - common_setup.tcl
# ==============================================================================
#
# Este arquivo prepara o Design Compiler para encontrar:
#
#   1. os seus arquivos RTL;
#   2. os scripts do laboratorio;
#   3. a biblioteca tecnologica SAED32 usada nos labs da Synopsys.
#
# O ponto mais importante para quem esta aprendendo:
#
#   RTL sozinho descreve comportamento e estrutura.
#   Biblioteca tecnologica diz quais portas fisicas existem para implementar isso.
#
# Sem target_library/link_library, a ferramenta nao sabe para qual conjunto de
# celulas deve mapear seu circuito.
#
# Este lab aceita dois layouts de biblioteca:
#
#   Layout A, preferido no material de Design Compiler NXT:
#
#     ref/DBs/saed32lvt_ss0p75v125c.db
#     ref/CLIBs/saed32_lvt.ndm
#     ref/tech/saed32nm_1p9m.tf
#
#   Layout B, usado no lab 04 ces_svrtl_2019.03:
#
#     ref/SAED32_2012-12-25/lib/stdcell_hvt/db_nldm/saed32hvt_ss0p75v125c.db
#
# Para os primeiros passos de constraints, precisamos principalmente da
# biblioteca logica .db. A parte fisica fica documentada aqui para voce entender
# o setup completo, mas o fluxo deste lab ainda e uma sintese logica simples.

if {![info exists REF_ROOT_PATH]} {
  set REF_ROOT_PATH "../../Aulas2Prints/07 Design Compiler NXT - RTL Synthesis/07 DCNXT_2021.06/ref"
}

if {![info exists REF_LIB_PATH]} {
  set REF_LIB_PATH ""
}

if {![info exists TARGET_DB_NAME]} {
  set TARGET_DB_NAME "saed32lvt_ss0p75v125c.db"
}

if {![info exists DRIVE_LIB_NAME]} {
  set DRIVE_LIB_NAME "saed32lvt_ss0p75v125c"
}

if {![info exists DRIVE_CELL_NAME]} {
  set DRIVE_CELL_NAME "NBUFFX2_LVT"
}

if {![info exists LOAD_CELL_NAME]} {
  set LOAD_CELL_NAME "NBUFFX16_LVT"
}

set LAB03_DRIVE_LIB_NAME  $DRIVE_LIB_NAME
set LAB03_DRIVE_CELL_NAME $DRIVE_CELL_NAME
set LAB03_LOAD_CELL_NAME  $LOAD_CELL_NAME

set LAB03_DB_PATH     ""
set LAB03_CLIB_PATH   ""
set LAB03_TECH_PATH   ""
set LAB03_TARGET_FILE $TARGET_DB_NAME

if {[file isdirectory "$REF_ROOT_PATH/DBs"]} {
  set LAB03_DB_PATH   "$REF_ROOT_PATH/DBs"
  set LAB03_CLIB_PATH "$REF_ROOT_PATH/CLIBs"
  set LAB03_TECH_PATH "$REF_ROOT_PATH/tech"
  puts "INFO Lab03: usando layout DC NXT ref/DBs, ref/CLIBs, ref/tech."
} elseif {$REF_LIB_PATH ne "" && [file isdirectory "$REF_LIB_PATH/lib/stdcell_hvt/db_nldm"]} {
  set LAB03_DB_PATH   "$REF_LIB_PATH/lib/stdcell_hvt/db_nldm"
  set LAB03_CLIB_PATH "$REF_LIB_PATH/lib/stdcell_hvt/ndm"
  set LAB03_TECH_PATH "$REF_LIB_PATH/tech"
  set LAB03_TARGET_FILE "saed32hvt_ss0p75v125c.db"
  set LAB03_DRIVE_LIB_NAME  "saed32hvt_ss0p75v125c"
  set LAB03_DRIVE_CELL_NAME "NBUFFX2_HVT"
  set LAB03_LOAD_CELL_NAME  "NBUFFX16_HVT"
  puts "INFO Lab03: usando layout legado SAED32_2012-12-25."
} else {
  puts "AVISO Lab03: nao encontrei a pasta de bibliotecas SAED32."
  puts "AVISO Lab03: REF_ROOT_PATH=$REF_ROOT_PATH"
  puts "AVISO Lab03: REF_LIB_PATH=$REF_LIB_PATH"
  puts "AVISO Lab03: rode make find-lib e passe REF_ROOT=/caminho/ref."
}

# search_path e a lista de lugares onde o DC procura arquivos.
# Usamos list/concat para lidar melhor com caminhos com espacos.
set_app_var search_path [concat $search_path [list \
  "../rtl" \
  "./scripts" \
  "./mapped" \
  "./unmapped" \
  "$LAB03_DB_PATH" \
  "$LAB03_CLIB_PATH" \
  "$LAB03_TECH_PATH" \
]]

# Biblioteca alvo: e a biblioteca para a qual o circuito sera sintetizado.
# No material de DC NXT, a forma didatica e:
#
#   set TARGET_LIBRARY_FILES saed32lvt_ss0p75v125c.db
#
# Aqui mantemos isso parametrizado para permitir trocar LVT/HVT depois.
set TARGET_LIBRARY_FILES [list $LAB03_TARGET_FILE]
set_app_var target_library $TARGET_LIBRARY_FILES

# link_library diz como resolver referencias durante o link.
#
# O "*" significa: tambem procure nos designs ja carregados em memoria.
# Isso importa quando mini_datapath instancia alu e regbank.
set_app_var link_library [concat [list "*"] $target_library]

# DesignWare:
#
# Operacoes como multiplicacao e divisao podem ser implementadas com componentes
# especiais da Synopsys. Em alguns ambientes, dw_foundation.sldb ja esta no
# caminho padrao. Mantemos a configuracao visivel porque ela e parte importante
# do que o lab 04 quer que voce perceba: operadores de alto nivel podem virar
# datapaths otimizados.
set_app_var synthetic_library [list "dw_foundation.sldb"]
set_app_var link_library [concat [list "*"] $target_library $synthetic_library]

puts "INFO Lab03: REF_ROOT_PATH=$REF_ROOT_PATH"
puts "INFO Lab03: REF_LIB_PATH=$REF_LIB_PATH"
puts "INFO Lab03: DB path=$LAB03_DB_PATH"
puts "INFO Lab03: target_library=$target_library"
puts "INFO Lab03: synthetic_library=$synthetic_library"
puts "INFO Lab03: driving lib/cell=$LAB03_DRIVE_LIB_NAME/$LAB03_DRIVE_CELL_NAME"
puts "INFO Lab03: load reference=$LAB03_DRIVE_LIB_NAME/$LAB03_LOAD_CELL_NAME/A"
