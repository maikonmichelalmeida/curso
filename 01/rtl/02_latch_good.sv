// ==============================================================================
// ERRO 02 corrigido - atribuicao default evita latch
// ==============================================================================
//
// Intencao do circuito:
//   Quando sel=1, y recebe a.
//   Quando sel=0, y deve ser 0.
//
// Correcao:
//   y recebe um valor default no inicio do always_comb.
//   Depois, casos especificos sobrescrevem esse default.
//
// Licao:
//   Atribuicao default e uma tecnica simples para evitar latch acidental.

module latch_dut (
    input  logic clk,
    input  logic rst_n,
    input  logic a,
    input  logic sel,
    output logic y
);

    always_comb begin
        y = 1'b0;

        if (sel) begin
            y = a;
        end
    end

endmodule
