`timescale 1ns/1ps

module tb_02_latch;

    logic clk;
    logic rst_n;
    logic a;
    logic sel;
    logic y;
    int errors;

    latch_dut dut (
        .clk   (clk),
        .rst_n (rst_n),
        .a     (a),
        .sel   (sel),
        .y     (y)
    );

    always #5 clk = ~clk;

    task automatic expect_y(input string label, input logic expected);
        begin
            #1;
            $display("T=%0t %-28s sel=%0b a=%0b y=%0b expected=%0b",
                     $time, label, sel, a, y, expected);

            if (y !== expected) begin
                $display("  OBSERVE: y reteve valor antigo. Isso e comportamento de latch.");
                errors++;
            end
        end
    endtask

    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_02_latch);

        clk = 1'b0;
        rst_n = 1'b1;
        a = 1'b0;
        sel = 1'b0;
        errors = 0;

        $display("============================================================");
        $display("EX02 - latch nao intencional");
        $display("Funcao esperada: se sel=1, y=a; se sel=0, y=0.");
        $display("No CASE=bad, y fica sem atribuicao quando sel=0.");
        $display("============================================================");

        expect_y("inicio sel=0", 1'b0);

        a = 1'b1;
        sel = 1'b1;
        expect_y("sel=1 copia a=1", 1'b1);

        // Ponto central: voltamos sel para 0.
        // O codigo correto joga y para 0.
        // O codigo ruim deixa y sem nova atribuicao e ele retem 1.
        a = 1'b0;
        sel = 1'b0;
        expect_y("sel=0 deveria zerar", 1'b0);

        a = 1'b1;
        sel = 1'b0;
        expect_y("sel=0 ignora a", 1'b0);

        sel = 1'b1;
        expect_y("sel=1 copia a=1 de novo", 1'b1);

        if (errors == 0) begin
            $display("TEST_RESULT: PASS");
        end else begin
            $display("TEST_RESULT: FAIL errors=%0d", errors);
        end

        $finish;
    end

endmodule
