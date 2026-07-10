`timescale 1ns/1ps

// Teste simples do registrador.
// Verifica reset, escrita com enable e manutencao do valor sem enable.

module tb_regbank;

    localparam int unsigned WIDTH = 8;

    logic             clk;
    logic             rst;
    logic             wr_en;
    logic [WIDTH-1:0] din;
    logic [WIDTH-1:0] dout;

    int errors;

    regbank #(.WIDTH(WIDTH)) dut (
        .clk   (clk),
        .rst   (rst),
        .wr_en (wr_en),
        .din   (din),
        .dout  (dout)
    );

    always #5ns clk = ~clk;

    task automatic confere(input logic [WIDTH-1:0] esperado);
        begin
            if (dout !== esperado) begin
                $display("ERRO regbank: esperado=%h obtido=%h", esperado, dout);
                errors++;
            end else begin
                $display("OK regbank: dout=%h", dout);
            end
        end
    endtask

    initial begin
        $fsdbDumpfile("regbank.fsdb");
        $fsdbDumpvars(0, tb_regbank);

        clk    = 1'b0;
        rst    = 1'b0;
        wr_en  = 1'b0;
        din    = '0;
        errors = 0;

        rst = 1'b1;
        #1ns;
        confere('0);
        rst = 1'b0;

        din   = 8'hab;
        wr_en = 1'b1;
        @(posedge clk);
        #1ns;
        confere(8'hab);

        din   = 8'hcd;
        wr_en = 1'b0;
        @(posedge clk);
        #1ns;
        confere(8'hab);

        if (errors == 0) begin
            $display("TEST_RESULT: PASS");
        end else begin
            $display("TEST_RESULT: FAIL com %0d erro(s)", errors);
        end

        $finish;
    end

endmodule
