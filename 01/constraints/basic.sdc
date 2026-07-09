# ==============================================================================
# Constraints basicas do Lab 01
# ==============================================================================
#
# Este arquivo e propositalmente simples. O objetivo do lab 01 nao e fechar
# timing agressivo, mas ver como o sintetizador interpreta RTL.
#
# Mesmo assim, ja comecamos do jeito certo:
# - clock definido;
# - delays de entrada e saida;
# - carga nas saidas;
# - reset tratado como caminho falso.

set CLK_PERIOD 10.000

set clk_ports [get_ports -quiet clk]

if {[sizeof_collection $clk_ports] > 0} {
    create_clock -name lab_clk -period $CLK_PERIOD $clk_ports

    # Pequena margem para incerteza do clock.
    set_clock_uncertainty 0.100 [get_clocks lab_clk]

    # Entradas chegam 1 ns depois da borda do clock.
    # Nem todo exemplo tem reset. Por isso usamos uma colecao defensiva.
    set all_in_except_clk [remove_from_collection [all_inputs] $clk_ports]
    if {[sizeof_collection $all_in_except_clk] > 0} {
        set_input_delay -clock lab_clk 1.000 $all_in_except_clk
        set_input_transition 0.100 $all_in_except_clk
    }

    # Saidas precisam estar estaveis 1 ns antes da borda seguinte.
    if {[sizeof_collection [all_outputs]] > 0} {
        set_output_delay -clock lab_clk 1.000 [all_outputs]
        set_load 0.050 [all_outputs]
    }
} else {
    puts "INFO: nenhum port clk encontrado. Constraints de clock foram ignoradas."
}

# Reset assincrono, quando existir, fica fora do fechamento funcional de timing.
set rst_ports [get_ports -quiet {rst rst_n reset reset_n}]
if {[sizeof_collection $rst_ports] > 0} {
    set_false_path -from $rst_ports
}

check_timing
