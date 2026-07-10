`timescale 1ns/1ps

// =============================================================================
// Testbench do mini_datapath
// =============================================================================
//
// Este testbench e intencionalmente simples e procedural.
//
// Ele nao tenta ser UVM, nao usa classes e nao usa scoreboard sofisticado.
// O objetivo do Lab 03 e constraints e sintese. Entao o testbench precisa apenas
// provar que a integracao ALU + registradores esta correta antes da sintese.
//
// Sequencia de cada operacao:
//
//   1. aplica operandos nas entradas externas;
//   2. ativa load_operands por um ciclo;
//   3. espera a ALU combinacional estabilizar;
//   4. ativa capture_result por um ciclo;
//   5. confere result_out, zero_out e error_out.
//
// Essa sequencia espelha o hardware:
//
//   ciclo N:   operandos entram nos registradores
//   ciclo N+1: ALU calcula a partir dos registradores
//   ciclo N+2: resultado e capturado

module tb_mini_datapath;

    localparam int unsigned WIDTH = 8;

    localparam logic [2:0] OP_ADD = 3'b000;
    localparam logic [2:0] OP_SUB = 3'b001;
    localparam logic [2:0] OP_MUL = 3'b010;
    localparam logic [2:0] OP_DIV = 3'b011;

    logic               clk;
    logic               rst;
    logic               load_operands;
    logic               capture_result;
    logic [WIDTH-1:0]   data_in_a;
    logic [WIDTH-1:0]   data_in_b;
    logic [2:0]         op;
    logic               invalid_data;
    logic [2*WIDTH-1:0] result_out;
    logic               zero_out;
    logic               error_out;
    logic [WIDTH-1:0]   operand_a_q;
    logic [WIDTH-1:0]   operand_b_q;
    logic [2*WIDTH-1:0] alu_out_comb;

    int errors;

    mini_datapath #(.WIDTH(WIDTH)) dut (
        .clk            (clk),
        .rst            (rst),
        .load_operands  (load_operands),
        .capture_result (capture_result),
        .data_in_a      (data_in_a),
        .data_in_b      (data_in_b),
        .op             (op),
        .invalid_data   (invalid_data),
        .result_out     (result_out),
        .zero_out       (zero_out),
        .error_out      (error_out),
        .operand_a_q    (operand_a_q),
        .operand_b_q    (operand_b_q),
        .alu_out_comb   (alu_out_comb)
    );

    initial begin
        clk = 1'b0;
        forever #5ns clk = ~clk; // periodo de 10 ns na simulacao RTL.
    end

    task automatic reset_dut;
        begin
            rst            = 1'b1;
            load_operands  = 1'b0;
            capture_result = 1'b0;
            data_in_a      = '0;
            data_in_b      = '0;
            op             = OP_ADD;
            invalid_data   = 1'b0;
            repeat (2) @(posedge clk);
            rst = 1'b0;
            @(posedge clk);
        end
    endtask

    task automatic executa_operacao(
        input logic [WIDTH-1:0]   a,
        input logic [WIDTH-1:0]   b,
        input logic [2:0]         op_teste,
        input logic               invalido,
        input logic [2*WIDTH-1:0] esperado_resultado,
        input logic               esperado_zero,
        input logic               esperado_error
    );
        begin
            // Etapa 1: preparar entradas externas antes da borda de captura.
            data_in_a      = a;
            data_in_b      = b;
            op             = op_teste;
            invalid_data   = invalido;
            load_operands  = 1'b1;
            capture_result = 1'b0;
            @(posedge clk);

            // Etapa 2: desligar escrita dos operandos. Depois desta borda,
            // operand_a_q e operand_b_q ja contem os valores de entrada.
            @(negedge clk);
            load_operands = 1'b0;
            #1ns;

            // Etapa 3: capturar resultado da ALU no registrador de resultado.
            capture_result = 1'b1;
            @(posedge clk);
            @(negedge clk);
            capture_result = 1'b0;
            #1ns;

            if ((result_out !== esperado_resultado) ||
                (zero_out   !== esperado_zero) ||
                (error_out  !== esperado_error)) begin
                $display("ERRO mini_datapath: a=%0d b=%0d op=%b invalido=%b",
                         a, b, op_teste, invalido);
                $display("  observado result=%h zero=%b error=%b alu_comb=%h",
                         result_out, zero_out, error_out, alu_out_comb);
                $display("  esperado  result=%h zero=%b error=%b",
                         esperado_resultado, esperado_zero, esperado_error);
                errors++;
            end else begin
                $display("OK mini_datapath: a=%0d b=%0d op=%b result=%h",
                         a, b, op_teste, result_out);
            end
        end
    endtask

    initial begin
        $fsdbDumpfile("mini_datapath.fsdb");
        $fsdbDumpvars(0, tb_mini_datapath);

        errors = 0;
        reset_dut();

        executa_operacao(8'd10,  8'd5, OP_ADD, 1'b0, 16'h000f, 1'b0, 1'b0);
        executa_operacao(8'd10,  8'd3, OP_SUB, 1'b0, 16'h0007, 1'b0, 1'b0);
        executa_operacao(8'd3,  8'd10, OP_SUB, 1'b0, 16'hfff9, 1'b0, 1'b0);
        executa_operacao(8'd12, 8'd10, OP_MUL, 1'b0, 16'h0078, 1'b0, 1'b0);
        executa_operacao(8'd100, 8'd4, OP_DIV, 1'b0, 16'h0019, 1'b0, 1'b0);
        executa_operacao(8'd7,   8'd7, OP_SUB, 1'b0, 16'h0000, 1'b1, 1'b0);
        executa_operacao(8'd10,  8'd0, OP_DIV, 1'b0, 16'hffff, 1'b0, 1'b1);
        executa_operacao(8'd10,  8'd5, OP_ADD, 1'b1, 16'hffff, 1'b0, 1'b1);

        if (errors == 0) begin
            $display("TEST_RESULT: PASS");
        end else begin
            $display("TEST_RESULT: FAIL com %0d erro(s)", errors);
        end

        $finish;
    end

endmodule
