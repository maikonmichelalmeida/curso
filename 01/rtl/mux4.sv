// =============================================================================
// Lab 01 - Mux 4:1
// =============================================================================
//
// Este e o RTL mais simples do nosso treino.
//
// Um mux 4:1 escolhe uma entre quatro entradas:
//
//   sel = 2'b00 -> y recebe d0
//   sel = 2'b01 -> y recebe d1
//   sel = 2'b10 -> y recebe d2
//   sel = 2'b11 -> y recebe d3
//
// Por enquanto nao estamos estudando sintese, timing ou constraints.
// Estamos apenas lembrando o ciclo minimo:
//
//   RTL -> testbench -> filelist -> make comp -> make sim -> waveform

module mux4 #(
    parameter int WIDTH = 8
) (
    input  logic [WIDTH-1:0] d0,
    input  logic [WIDTH-1:0] d1,
    input  logic [WIDTH-1:0] d2,
    input  logic [WIDTH-1:0] d3,
    input  logic [1:0]       sel,
    output logic [WIDTH-1:0] y
);

    // Logica combinacional:
    // sempre que qualquer entrada mudar, a saida deve ser recalculada.
    //
    // always_comb e melhor do que always @(*) para SystemVerilog moderno,
    // porque deixa claro para ferramenta e para o leitor que este bloco
    // nao deve criar registrador nem latch.
    always_comb begin
        unique case (sel)
            2'b00: y = d0;
            2'b01: y = d1;
            2'b10: y = d2;
            2'b11: y = d3;
            default: y = '0;
        endcase
    end

endmodule
