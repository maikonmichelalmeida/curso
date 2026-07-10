`timescale 1ns/1ps

// Teste simples da memoria.
// Verifica uma escrita sincrona e uma leitura combinacional.

module tb_memory;

    localparam int unsigned WIDTH = 8;

    logic               clk;
    logic               memoryWrite;
    logic               memoryRead;
    logic [2*WIDTH-1:0] memoryWriteData;
    logic [7:0]         memoryAddress;
    logic [2*WIDTH-1:0] memoryOutData;

    int errors;

    memory #(.WIDTH(WIDTH)) dut (
        .clk             (clk),
        .memoryWrite     (memoryWrite),
        .memoryRead      (memoryRead),
        .memoryWriteData (memoryWriteData),
        .memoryAddress   (memoryAddress),
        .memoryOutData   (memoryOutData)
    );

    always #5ns clk = ~clk;

    task automatic confere(input logic [2*WIDTH-1:0] esperado);
        begin
            #1ns;
            if (memoryOutData !== esperado) begin
                $display("ERRO memory: addr=%0d esperado=%h obtido=%h",
                         memoryAddress, esperado, memoryOutData);
                errors++;
            end else begin
                $display("OK memory: addr=%0d data=%h", memoryAddress, memoryOutData);
            end
        end
    endtask

    initial begin
        $fsdbDumpfile("memory.fsdb");
        $fsdbDumpvars(0, tb_memory);
        $fsdbDumpMDA(0, dut);

        clk             = 1'b0;
        memoryWrite     = 1'b0;
        memoryRead      = 1'b0;
        memoryWriteData = '0;
        memoryAddress   = 8'd0;
        errors          = 0;

        memoryAddress   = 8'd3;
        memoryWriteData = 16'habcd;
        memoryWrite     = 1'b1;

        @(posedge clk);
        #1ns;
        memoryWrite = 1'b0;

        memoryRead = 1'b1;
        confere(16'habcd);

        memoryRead = 1'b0;
        confere(16'h0000);

        if (errors == 0) begin
            $display("TEST_RESULT: PASS");
        end else begin
            $display("TEST_RESULT: FAIL com %0d erro(s)", errors);
        end

        $finish;
    end

endmodule
