// =============================================================================
// Modulo: mux4
// =============================================================================
//
// Mux 4:1 parametrizavel.
//
// Este modulo e o mesmo conceito do Lab 01, agora usando os nomes do seu
// projeto original: din1, din2, din3, din4, select e dout.

module mux4 #(
    parameter int unsigned WIDTH = 8
) (
    input  logic [WIDTH-1:0] din1,
    input  logic [WIDTH-1:0] din2,
    input  logic [WIDTH-1:0] din3,
    input  logic [WIDTH-1:0] din4,
    input  logic [1:0]       select,
    output logic [WIDTH-1:0] dout
);

    // Logica combinacional pura.
    // Comecamos por esse estilo porque ele e facil de simular e tambem e uma
    // boa pratica para sintese mais adiante.
    always_comb begin
        case (select)
            2'b00:   dout = din1;
            2'b01:   dout = din2;
            2'b10:   dout = din3;
            2'b11:   dout = din4;
            default: dout = '0;
        endcase
    end

endmodule
