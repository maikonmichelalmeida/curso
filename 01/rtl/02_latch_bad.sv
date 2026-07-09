// ==============================================================================
// ERRO 02 - latch nao intencional
// ==============================================================================
//
// Intencao do circuito:
//   Quando sel=1, y recebe a.
//   Quando sel=0, y deveria ser 0.
//
// Problema:
//   O codigo nao diz o que acontece com y quando sel=0.
//
// Efeito:
//   Para preservar o valor anterior de y, a ferramenta precisa inferir memoria.
//   Em logica combinacional, essa memoria vira um latch.
//
// Licao:
//   Em always_comb, atribua um valor default para toda saida controlada pelo
//   bloco, ou cubra todos os caminhos de if/case.

module latch_dut (
    input  logic clk,
    input  logic rst_n,
    input  logic a,
    input  logic sel,
    output logic y
);

    // clk e rst_n existem para a interface ficar parecida com os outros exemplos.
    // Eles nao deveriam ser necessarios para uma logica combinacional pura.
    // O fato de y "lembrar" valor anterior aqui e justamente o problema.

    always_comb begin
        if (sel) begin
            y = a;
        end

        // ERRADO:
        // Falta o else.
        // Quando sel=0, y fica sem nova atribuicao e precisa reter valor.
    end

endmodule
