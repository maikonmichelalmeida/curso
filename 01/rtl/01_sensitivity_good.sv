// ==============================================================================
// ERRO 01 corrigido - always_comb
// ==============================================================================
//
// Intencao do circuito:
//   y = (a & b) | c
//
// Correcao:
//   always_comb monta automaticamente a sensibilidade a partir dos sinais lidos.
//   Se a, b ou c mudarem, o bloco reexecuta.
//
// Licao:
//   Para logica combinacional em SystemVerilog, prefira always_comb.

module sensitivity_dut (
    input  logic clk,
    input  logic a,
    input  logic b,
    input  logic c,
    output logic y
);

    // clk esta presente para manter a interface parecida com blocos reais de RTL
    // e permitir o uso do mesmo arquivo SDC. Ele nao deveria afetar esta logica.

    always_comb begin
        y = (a & b) | c;
    end

endmodule
