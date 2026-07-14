// =============================================================================
// Lab 02B - circuito introdutorio para sintese logica
// =============================================================================
//
// Este modulo foi mantido propositalmente pequeno. A meta nao e construir um
// processador nem demonstrar recursos avancados de SystemVerilog. A meta e
// olhar para um RTL simples e acompanhar sua transformacao em celulas da
// biblioteca SAED32 dentro do Design Compiler.
//
// Caminho de dados:
//
//   a -> a_q --\
//                +-> somador de 9 bits -> registrador result -> result
//   b -> b_q --/
//
// Quantidade de armazenamento esperada antes de qualquer otimizacao especial:
//
//   a_q    : 8 bits = 8 flip-flops
//   b_q    : 8 bits = 8 flip-flops
//   result : 9 bits = 9 flip-flops
//                       --------------
//                       25 flip-flops
//
// O somador nao e um registrador. Ele e logica combinacional entre os dois
// estagios sequenciais. E justamente esse caminho reg_a -> soma -> reg_result
// que o clock de 10 ns passara a limitar na segunda parte do laboratorio.
//
// Reset e enable foram mantidos simples:
//
//   - rst e sincrono e ativo em nivel alto. Portanto, ele so altera os
//     registradores na borda de subida do clock;
//   - enable=1 permite que todos os registradores capturem novos valores;
//   - enable=0 faz os registradores manterem os valores anteriores.
//
// Como as atribuicoes sequenciais usam <=, o registrador result recebe a soma
// dos valores ANTIGOS de a_q e b_q na mesma borda em que a_q e b_q recebem as
// novas entradas. Isso cria dois estagios de pipeline e sera visivel na onda.

module synth_intro (
    input  logic       clk,
    input  logic       rst,
    input  logic       enable,
    input  logic [7:0] a,
    input  logic [7:0] b,
    output logic [8:0] result
);

    // Primeiro estagio: 16 bits de armazenamento no total.
    logic [7:0] a_q;
    logic [7:0] b_q;

    // O bit extra evita perder o carry da soma de dois numeros de 8 bits.
    // Exemplo: 255 + 255 = 510, valor que precisa de 9 bits.
    logic [8:0] sum;

    // Registradores de entrada.
    // Nao existe latch aqui: always_ff descreve armazenamento acionado por
    // borda, e todos os caminhos relevantes preservam ou atualizam o estado.
    always_ff @(posedge clk) begin
        if (rst) begin
            a_q <= 8'd0;
            b_q <= 8'd0;
        end else if (enable) begin
            a_q <= a;
            b_q <= b;
        end
    end

    // Logica combinacional. As extensoes com 1'b0 tornam explicito que a soma
    // possui 9 bits e que os operandos sao tratados como valores sem sinal.
    assign sum = {1'b0, a_q} + {1'b0, b_q};

    // Segundo estagio: 9 bits de armazenamento.
    // result e uma porta de saida e, ao mesmo tempo, o proprio registrador de
    // saida. Por isso nao ha necessidade de criar outro sinal result_q.
    always_ff @(posedge clk) begin
        if (rst) begin
            result <= 9'd0;
        end else if (enable) begin
            result <= sum;
        end
    end

endmodule
