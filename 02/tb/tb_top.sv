`timescale 1ns/1ps

// Teste geral simples do top.
//
// Este teste nao tenta cobrir todas as instrucoes.
// Ele so verifica se a integracao principal executa uma soma:
//
//   din_1 + din_2 = 14 + 17 = 31

module tb_top;

    localparam int unsigned WIDTH = 8;

    localparam logic [1:0] SEL_DIN1 = 2'b00;
    localparam logic [1:0] SEL_DIN2 = 2'b01;
    localparam logic [2:0] OP_ADD   = 3'b000;
    localparam logic [6:0] CMD_ADD  = {SEL_DIN1, SEL_DIN2, OP_ADD};

    logic               clk;
    logic               rst;
    logic [6:0]         cmd_in;
    logic [WIDTH-1:0]   din_1;
    logic [WIDTH-1:0]   din_2;
    logic [WIDTH-1:0]   din_3;
    logic [2*WIDTH-1:0] output_data;
    logic               cpu_rdy;
    logic               zero;
    logic               error;

    int errors;

    top #(.WIDTH(WIDTH)) dut (
        .clk         (clk),
        .rst         (rst),
        .cmd_in      (cmd_in),
        .din_1       (din_1),
        .din_2       (din_2),
        .din_3       (din_3),
        .output_data (output_data),
        .cpu_rdy     (cpu_rdy),
        .zero        (zero),
        .error       (error)
    );

    always #5ns clk = ~clk;

    task automatic espera_borda();
        begin
            @(posedge clk);
            #1ns;
        end
    endtask

    initial begin
        $fsdbDumpfile("top.fsdb");
        $fsdbDumpvars(0, tb_top);

        clk    = 1'b0;
        rst    = 1'b1;
        errors = 0;

        din_1  = 8'd14;
        din_2  = 8'd17;
        din_3  = 8'd8;
        cmd_in = CMD_ADD;

        // Mantem reset ativo por um ciclo, depois libera.
        espera_borda();
        rst = 1'b0;

        // O top usa uma pequena maquina de estados.
        // Apos liberar reset, esperamos algumas bordas ate o resultado ser
        // registrado na saida.
        repeat (4) espera_borda();

        if ((output_data !== 16'h001f) || (zero !== 1'b0) || (error !== 1'b0)) begin
            $display("ERRO top: esperado output_data=001f zero=0 error=0");
            $display("          obtido output_data=%h zero=%b error=%b cpu_rdy=%b",
                     output_data, zero, error, cpu_rdy);
            errors++;
        end else begin
            $display("OK top: 14 + 17 = %0d", output_data);
        end

        if (errors == 0) begin
            $display("TEST_RESULT: PASS");
        end else begin
            $display("TEST_RESULT: FAIL com %0d erro(s)", errors);
        end

        $finish;
    end

endmodule
