# ==============================================================================
# Lab 01 - Fluxo de sintese DC_NXT
# ==============================================================================
#
# Este arquivo responde: "o que a ferramenta deve fazer?"
# Ele foi mantido curto de proposito, seguindo a logica dos labs Synopsys:
#
#   setup -> analyze -> elaborate -> link -> constraints -> compile -> reports

puts "--- [DC_NXT] 1. Carregando setup ---"
source ../scripts/setup.tcl

foreach dir [list $REPORTS_PATH $OUTPUTS_PATH] {
    if {![file exists $dir]} {
        file mkdir $dir
    }
}

# SVF guarda informacoes que ajudam o Formality depois.
# Mesmo que Formality fique para outro lab, ja e bom ver onde esse arquivo nasce.
set_svf ${OUTPUTS_PATH}/${DESIGN_NAME}.svf

puts "--- [DC_NXT] 2. Lendo RTL ---"
if {![file exists $RTL_FILELIST]} {
    puts "ERRO: filelist RTL nao encontrado: $RTL_FILELIST"
    exit 1
}

# -vcs "-f filelist" permite usar a mesma ideia de filelist do VCS.
analyze -format sverilog -vcs "-f ${RTL_FILELIST}"

puts "--- [DC_NXT] 3. Elaborando top ---"
elaborate $DESIGN_NAME
current_design $DESIGN_NAME

puts "--- [DC_NXT] 4. Link com bibliotecas ---"
link
check_design > ${REPORTS_PATH}/${DESIGN_NAME}_check_design_pre.rpt

puts "--- [DC_NXT] 5. Aplicando constraints ---"
if {![file exists $SDC_FILE]} {
    puts "ERRO: SDC nao encontrado: $SDC_FILE"
    exit 1
}

source -echo -verbose $SDC_FILE
check_timing > ${REPORTS_PATH}/${DESIGN_NAME}_check_timing_pre.rpt

puts "--- [DC_NXT] 6. Sintetizando ---"
compile_ultra

puts "--- [DC_NXT] 7. Gerando relatorios ---"
report_area -hierarchy           > ${REPORTS_PATH}/${DESIGN_NAME}_area.rpt
report_timing -max_paths 20      > ${REPORTS_PATH}/${DESIGN_NAME}_timing.rpt
report_power                     > ${REPORTS_PATH}/${DESIGN_NAME}_power.rpt
report_qor                       > ${REPORTS_PATH}/${DESIGN_NAME}_qor.rpt
report_constraint -all_violators > ${REPORTS_PATH}/${DESIGN_NAME}_constraints.rpt
check_design                     > ${REPORTS_PATH}/${DESIGN_NAME}_check_design_post.rpt

puts "--- [DC_NXT] 8. Exportando artefatos ---"
change_names -rules verilog -hierarchy

write -format verilog -hierarchy -output ${OUTPUTS_PATH}/${DESIGN_NAME}_mapped.v
write -format ddc     -hierarchy -output ${OUTPUTS_PATH}/${DESIGN_NAME}.ddc
write_sdc -nosplit                  ${OUTPUTS_PATH}/${DESIGN_NAME}_final.sdc
write_sdf                           ${OUTPUTS_PATH}/${DESIGN_NAME}_delays.sdf

set_svf -off

puts "=================================================================="
puts "Sintese concluida."
puts "Relatorios: $REPORTS_PATH"
puts "Outputs:    $OUTPUTS_PATH"
puts "=================================================================="

exit
