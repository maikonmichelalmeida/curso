// =============================================================================
// Lab 03 - Mini datapath para estudo gradual de constraints
// =============================================================================
//
// Este e o bloco principal do Lab 03.
//
// Ele NAO e um datapath completo de CPU. Ele e um modulo pequeno que conecta:
//
//   1. dois registradores de entrada, baseados no seu regbank;
//   2. uma ALU combinacional, baseada na sua alu;
//   3. um registrador de resultado, tambem baseado no regbank.
//
// O objetivo e criar um circuito pequeno com:
//
//   - parte sequencial: registradores com clock/reset;
//   - parte combinacional: ALU entre registradores;
//   - entradas externas: data_in_a, data_in_b, op, invalid_data;
//   - saidas externas: result_out, zero_out, error_out.
//
// Isso e perfeito para constraints porque aparecem tres tipos de caminho:
//
//   A) entrada externa -> registrador
//      Exemplo: data_in_a entra no chip e precisa chegar ao reg_a.
//      No TCL, isso sera modelado com set_input_delay.
//
//   B) registrador -> ALU -> registrador
//      Exemplo: reg_a/reg_b alimentam a ALU, e result_reg captura o resultado.
//      No TCL, isso e limitado principalmente por create_clock.
//
//   C) registrador/logica -> saida externa
//      Exemplo: result_out sai do bloco e vai para algo fora do chip.
//      No TCL, isso sera modelado com set_output_delay.
//
// Por enquanto, nao ha controle complexo. O testbench dirige enables e operandos
// diretamente para que voce possa focar no fluxo:
//
//   simular -> sintetizar sem constraint -> aplicar clock -> aplicar I/O delays
//   -> aplicar cargas -> ler relatorios.

module mini_datapath #(
    parameter int unsigned WIDTH = 8
) (
    input  logic               clk,
    input  logic               rst,

    // Enables separados para deixar a experiencia didatica:
    //
    //   load_operands = 1
    //     captura data_in_a e data_in_b nos registradores de operandos.
    //
    //   capture_result = 1
    //     captura o resultado atual da ALU no registrador de resultado.
    //
    // Em uma CPU real, isso viria de uma unidade de controle. Aqui vem do
    // testbench para manter o laboratorio pequeno.
    input  logic               load_operands,
    input  logic               capture_result,

    input  logic [WIDTH-1:0]   data_in_a,
    input  logic [WIDTH-1:0]   data_in_b,
    input  logic [2:0]         op,
    input  logic               invalid_data,

    output logic [2*WIDTH-1:0] result_out,
    output logic               zero_out,
    output logic               error_out,

    // Saidas de observacao. Elas ajudam no testbench e na waveform.
    // Em um projeto final talvez voce nao exportasse isso, mas aqui e didatico.
    output logic [WIDTH-1:0]   operand_a_q,
    output logic [WIDTH-1:0]   operand_b_q,
    output logic [2*WIDTH-1:0] alu_out_comb
);

    logic [WIDTH-1:0]   reg_a_q;
    logic [WIDTH-1:0]   reg_b_q;
    logic [2*WIDTH-1:0] alu_result;
    logic               alu_zero;
    logic               alu_error;

    // O seu regbank tem WIDTH parametrizavel. Para os operandos, usamos WIDTH.
    regbank #(.WIDTH(WIDTH)) u_reg_a (
        .clk   (clk),
        .rst   (rst),
        .wr_en (load_operands),
        .din   (data_in_a),
        .dout  (reg_a_q)
    );

    regbank #(.WIDTH(WIDTH)) u_reg_b (
        .clk   (clk),
        .rst   (rst),
        .wr_en (load_operands),
        .din   (data_in_b),
        .dout  (reg_b_q)
    );

    // A ALU e combinacional. Ela responde sempre que reg_a_q, reg_b_q, op ou
    // invalid_data mudam. Ela nao tem clock.
    //
    // Este e o "miolo" do caminho de timing registrador -> registrador.
    alu #(.WIDTH(WIDTH)) u_alu (
        .in1          (reg_a_q),
        .in2          (reg_b_q),
        .op           (op),
        .invalid_data (invalid_data),
        .out          (alu_result),
        .zero         (alu_zero),
        .error        (alu_error)
    );

    // O resultado da ALU tem 2*WIDTH bits. Por isso instanciamos o mesmo regbank
    // com WIDTH=2*WIDTH para armazenar o resultado inteiro.
    regbank #(.WIDTH(2*WIDTH)) u_result_reg (
        .clk   (clk),
        .rst   (rst),
        .wr_en (capture_result),
        .din   (alu_result),
        .dout  (result_out)
    );

    // Flags registradas separadamente.
    //
    // Poderiamos criar outro modulo regbank de 1 bit para cada flag, mas aqui
    // fica mais legivel escrever o always_ff diretamente. O efeito de timing e
    // o mesmo: sao registradores que capturam saidas combinacionais da ALU.
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            zero_out  <= 1'b0;
            error_out <= 1'b0;
        end else if (capture_result) begin
            zero_out  <= alu_zero;
            error_out <= alu_error;
        end
    end

    assign operand_a_q  = reg_a_q;
    assign operand_b_q  = reg_b_q;
    assign alu_out_comb = alu_result;

endmodule
