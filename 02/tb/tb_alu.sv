`timescale 1ns/1ps

// Teste simples da ALU.
// Aqui ainda nao usamos scoreboard nem classe. Cada caso chama uma task.

module tb_alu;

    localparam int unsigned WIDTH = 8;

    localparam logic [2:0] OP_ADD = 3'b000;
    localparam logic [2:0] OP_SUB = 3'b001;
    localparam logic [2:0] OP_MUL = 3'b010;
    localparam logic [2:0] OP_DIV = 3'b011;

    logic [WIDTH-1:0]   in1;
    logic [WIDTH-1:0]   in2;
    logic [2:0]         op;
    logic               invalid_data;
    logic [2*WIDTH-1:0] out;
    logic               zero;
    logic               error;

    int errors;

    alu #(.WIDTH(WIDTH)) dut (
        .in1          (in1),
        .in2          (in2),
        .op           (op),
        .invalid_data (invalid_data),
        .out          (out),
        .zero         (zero),
        .error        (error)
    );

    task automatic aplica_e_confere(
        input logic [WIDTH-1:0]   a,
        input logic [WIDTH-1:0]   b,
        input logic [2:0]         op_teste,
        input logic               invalido,
        input logic [2*WIDTH-1:0] esperado_out,
        input logic               esperado_zero,
        input logic               esperado_error
    );
        begin
            in1          = a;
            in2          = b;
            op           = op_teste;
            invalid_data = invalido;
            #1ns;

            if ((out !== esperado_out) ||
                (zero !== esperado_zero) ||
                (error !== esperado_error)) begin
                $display("ERRO alu: op=%b in1=%0d in2=%0d out=%h zero=%b error=%b",
                         op, in1, in2, out, zero, error);
                $display("          esperado out=%h zero=%b error=%b",
                         esperado_out, esperado_zero, esperado_error);
                errors++;
            end else begin
                $display("OK alu: op=%b in1=%0d in2=%0d out=%h", op, in1, in2, out);
            end
        end
    endtask

    initial begin
        $fsdbDumpfile("alu.fsdb");
        $fsdbDumpvars(0, tb_alu);

        errors = 0;

        aplica_e_confere(8'd10,  8'd5, OP_ADD, 1'b0, 16'h000f, 1'b0, 1'b0);
        aplica_e_confere(8'd10,  8'd3, OP_SUB, 1'b0, 16'h0007, 1'b0, 1'b0);
        aplica_e_confere(8'd3,  8'd10, OP_SUB, 1'b0, 16'hfff9, 1'b0, 1'b0);
        aplica_e_confere(8'd12, 8'd10, OP_MUL, 1'b0, 16'h0078, 1'b0, 1'b0);
        aplica_e_confere(8'd100, 8'd4, OP_DIV, 1'b0, 16'h0019, 1'b0, 1'b0);
        aplica_e_confere(8'd7,   8'd7, OP_SUB, 1'b0, 16'h0000, 1'b1, 1'b0);
        aplica_e_confere(8'd10,  8'd0, OP_DIV, 1'b0, 16'hffff, 1'b0, 1'b1);
        aplica_e_confere(8'd10,  8'd5, OP_ADD, 1'b1, 16'hffff, 1'b0, 1'b1);

        if (errors == 0) begin
            $display("TEST_RESULT: PASS");
        end else begin
            $display("TEST_RESULT: FAIL com %0d erro(s)", errors);
        end

        $finish;
    end

endmodule
