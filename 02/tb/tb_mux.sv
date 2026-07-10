`timescale 1ns/1ps

// Teste simples do mux4.
// A ideia e testar as quatro selecoes possiveis.

module tb_mux;

    localparam int unsigned WIDTH = 8;

    logic [WIDTH-1:0] din1;
    logic [WIDTH-1:0] din2;
    logic [WIDTH-1:0] din3;
    logic [WIDTH-1:0] din4;
    logic [1:0]       select;
    logic [WIDTH-1:0] dout;

    int errors;

    mux4 #(.WIDTH(WIDTH)) dut (
        .din1   (din1),
        .din2   (din2),
        .din3   (din3),
        .din4   (din4),
        .select (select),
        .dout   (dout)
    );

    task automatic verifica(
        input logic [1:0]       sel_teste,
        input logic [WIDTH-1:0] esperado
    );
        begin
            select = sel_teste;
            #1ns;

            if (dout !== esperado) begin
                $display("ERRO mux: select=%b esperado=%h obtido=%h",
                         select, esperado, dout);
                errors++;
            end else begin
                $display("OK mux: select=%b dout=%h", select, dout);
            end
        end
    endtask

    initial begin
        $fsdbDumpfile("mux.fsdb");
        $fsdbDumpvars(0, tb_mux);

        errors = 0;
        din1 = 8'h11;
        din2 = 8'h22;
        din3 = 8'h33;
        din4 = 8'h44;

        verifica(2'b00, din1);
        verifica(2'b01, din2);
        verifica(2'b10, din3);
        verifica(2'b11, din4);

        if (errors == 0) begin
            $display("TEST_RESULT: PASS");
        end else begin
            $display("TEST_RESULT: FAIL com %0d erro(s)", errors);
        end

        $finish;
    end

endmodule
