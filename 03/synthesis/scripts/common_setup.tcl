# ==============================================================================
# Lab 03 - common_setup.tcl
# ==============================================================================
#
# Este arquivo segue a ideia da aula "Design Setup for Physical Synthesis":
#
#   common_setup.tcl = variaveis especificas do projeto
#   dc_setup.tcl     = script reutilizavel que aplica essas variaveis
#
# Em outras palavras: este e o arquivo que voce olha quando quer entender
# "quais bibliotecas estou usando?" e "onde esta a tecnologia?".
#
# A pasta REF_ROOT_PATH deve apontar para uma arvore neste formato:
#
#   ref/
#     DBs/
#       saed32lvt_ss0p75v125c.db
#     CLIBs/
#       saed32_lvt.ndm
#     tech/
#       saed32nm_1p9m.tf
#       saed32nm_1p9m_Cmax.tluplus
#       saed32nm_tf_itf_tluplus.map
#
# O Makefile passa REF_ROOT_PATH para ca. Se este arquivo for usado sozinho, o
# default didatico e ../ref.

if {![info exists REF_ROOT_PATH]} {
  set REF_ROOT_PATH "../ref"
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

if {![info exists ENABLE_PHYSICAL_SETUP]} {
  set ENABLE_PHYSICAL_SETUP 0
}

# ------------------------------------------------------------------------------
# Layout principal, no estilo DC NXT: ref/DBs, ref/CLIBs, ref/tech.
# ------------------------------------------------------------------------------

set LAB03_DB_PATH      "$REF_ROOT_PATH/DBs"
set LAB03_CLIB_PATH    "$REF_ROOT_PATH/CLIBs"
set LAB03_TECH_PATH    "$REF_ROOT_PATH/tech"
set LAB03_VERILOG_PATH "$REF_ROOT_PATH/verilog"

set TARGET_LIBS        [list $TARGET_DB_NAME]
set ADDL_LINK_LIBS     [list]
set NDM_REFERENCE_LIBS [list "$LAB03_CLIB_PATH/saed32_lvt.ndm"]
set NDM_DESIGN_LIB     "run/lab03_design.dlib"
set TECH_FILE          "$LAB03_TECH_PATH/saed32nm_1p9m.tf"
set TLUPLUS_MAX_FILE   "$LAB03_TECH_PATH/saed32nm_1p9m_Cmax.tluplus"
set MAP_FILE           "$LAB03_TECH_PATH/saed32nm_tf_itf_tluplus.map"

# search_path deve manter o search_path padrao da ferramenta. O dc_setup.tcl
# fara concat com a variavel existente, em vez de sobrescrever tudo.
set ADDL_SEARCH_PATH [list \
  "../rtl" \
  "./scripts" \
  "./mapped" \
  "./unmapped" \
  "$LAB03_DB_PATH" \
  "$LAB03_CLIB_PATH" \
  "$LAB03_TECH_PATH" \
  "$LAB03_VERILOG_PATH" \
]

# ------------------------------------------------------------------------------
# Compatibilidade com o layout antigo SAED32_2012-12-25, se REF_LIB_PATH for usado.
# Mantemos isso separado para nao confundir com o roteiro principal do Lab 03.
# ------------------------------------------------------------------------------

if {$REF_LIB_PATH ne "" && [file isdirectory "$REF_LIB_PATH/lib/stdcell_hvt/db_nldm"]} {
  set LAB03_DB_PATH      "$REF_LIB_PATH/lib/stdcell_hvt/db_nldm"
  set LAB03_CLIB_PATH    "$REF_LIB_PATH/lib/stdcell_hvt/ndm"
  set LAB03_TECH_PATH    "$REF_LIB_PATH/tech"
  set LAB03_VERILOG_PATH "$REF_LIB_PATH/lib/stdcell_hvt/verilog"

  set TARGET_LIBS        [list "saed32hvt_ss0p75v125c.db"]
  set NDM_REFERENCE_LIBS [list "$LAB03_CLIB_PATH/saed32_hvt.ndm"]
  set TECH_FILE          "$LAB03_TECH_PATH/saed32nm_1p9m.tf"
  set TLUPLUS_MAX_FILE   "$LAB03_TECH_PATH/saed32nm_1p9m_Cmax.tluplus"
  set MAP_FILE           "$LAB03_TECH_PATH/saed32nm_tf_itf_tluplus.map"

  set DRIVE_LIB_NAME  "saed32hvt_ss0p75v125c"
  set DRIVE_CELL_NAME "NBUFFX2_HVT"
  set LOAD_CELL_NAME  "NBUFFX16_HVT"

  set ADDL_SEARCH_PATH [list \
    "../rtl" \
    "./scripts" \
    "./mapped" \
    "./unmapped" \
    "$LAB03_DB_PATH" \
    "$LAB03_CLIB_PATH" \
    "$LAB03_TECH_PATH" \
    "$LAB03_VERILOG_PATH" \
  ]
}

set LAB03_DRIVE_LIB_NAME  $DRIVE_LIB_NAME
set LAB03_DRIVE_CELL_NAME $DRIVE_CELL_NAME
set LAB03_LOAD_CELL_NAME  $LOAD_CELL_NAME

puts "INFO common_setup: REF_ROOT_PATH=$REF_ROOT_PATH"
puts "INFO common_setup: TARGET_LIBS=$TARGET_LIBS"
puts "INFO common_setup: NDM_REFERENCE_LIBS=$NDM_REFERENCE_LIBS"
puts "INFO common_setup: TECH_FILE=$TECH_FILE"
puts "INFO common_setup: TLUPLUS_MAX_FILE=$TLUPLUS_MAX_FILE"
puts "INFO common_setup: MAP_FILE=$MAP_FILE"
