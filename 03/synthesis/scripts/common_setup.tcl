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

if {![info exists REF_LIB_PATH]} {
  set REF_LIB_PATH "../../Aulas2Prints/04 RTL Design Synthesis/04 ces_svrtl_2019.03/ref/SAED32_2012-12-25"
}

set DESIGN_REF_STDHVT_PATH "$REF_LIB_PATH/lib/stdcell_hvt"

# search_path e a lista de lugares onde o DC procura arquivos.
# Usamos list/concat para lidar melhor com caminhos com espacos.
set_app_var search_path [concat $search_path [list \
  "../rtl" \
  "./scripts" \
  "./mapped" \
  "./unmapped" \
  "$DESIGN_REF_STDHVT_PATH/db_nldm" \
  "$DESIGN_REF_STDHVT_PATH/verilog" \
]]

# Biblioteca alvo: e a biblioteca para a qual o circuito sera sintetizado.
# O nome abaixo veio do lab 04 ces_svrtl_2019.03.
set TARGET_LIBRARY_FILES [list "saed32hvt_ss0p75v125c.db"]
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

puts "INFO Lab03: REF_LIB_PATH=$REF_LIB_PATH"
puts "INFO Lab03: target_library=$target_library"
puts "INFO Lab03: synthetic_library=$synthetic_library"
