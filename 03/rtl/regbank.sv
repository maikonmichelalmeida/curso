// =============================================================================
// Lab 03 - Banco/registrador didatico
// =============================================================================
//
// Este modulo preserva a ideia do seu regbank do Lab 02: um elemento sequencial
// parametrizavel, com clock, reset e enable de escrita.
//
// Observacao importante:
//
//   O nome "regbank" aqui ainda representa um registrador com enable, nao um
//   banco multiporta completo. Isso e intencional. Para estudar constraints,
//   tres registradores simples sao suficientes:
//
//     reg_a       guarda operando A
//     reg_b       guarda operando B
//     result_reg  guarda resultado da ALU
//
// O mini_datapath instancia este mesmo modulo tres vezes. Assim voce ve uma
// estrutura sequencial real, mas sem criar um processador inteiro.

module regbank #(
    parameter int unsigned WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst,
    input  logic             wr_en,
    input  logic [WIDTH-1:0] din,
    output logic [WIDTH-1:0] dout
);

    // Bloco sequencial:
    //
    //   - posedge clk: a escrita normal acontece na borda de subida do clock;
    //   - posedge rst: reset assincrono ativo em 1;
    //   - wr_en: quando 0, o registrador preserva o valor anterior.
    //
    // Do ponto de vista de timing, este bloco cria pontos de partida e chegada:
    //
    //   Saida Q deste registrador  -> logica combinacional -> entrada D de outro
    //   registrador.
    //
    // A constraint de clock limita quanto tempo essa logica pode gastar.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            dout <= '0;
        end else if (wr_en) begin
            dout <= din;
        end
    end

endmodule
