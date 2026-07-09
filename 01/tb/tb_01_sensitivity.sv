`timescale 1ns/1ps

module tb_01_sensitivity;

    logic a;
    logic b;
    logic c;
    logic y;
    logic clk;
    int errors;

    sensitivity_dut dut (
        .clk (clk),
        .a (a),
        .b (b),
        .c (c),
        .y (y)
    );

    always #5 clk = ~clk;

    task automatic check_value(input string label);
        logic expected;
        begin
            expected = (a & b) | c;
            #1;

            $display("T=%0t %-28s a=%0b b=%0b c=%0b y=%0b expected=%0b",
                     $time, label, a, b, c, y, expected);

            if (y !== expected) begin
                $display("  OBSERVE: mismatch encontrado. No codigo bad, mudar somente c nao reexecuta always @(a or b).");
                errors++;
            end
        end
    endtask

    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_01_sensitivity);

        errors = 0;
        clk = 1'b0;
        a = 1'b0;
        b = 1'b0;
        c = 1'b0;

        $display("============================================================");
        $display("EX01 - sensitivity list incompleta");
        $display("Funcao esperada: y = (a & b) | c");
        $display("No CASE=bad, a mudanca isolada de c deve expor o problema.");
        $display("============================================================");

        check_value("inicio");

        a = 1'b1;
        b = 1'b1;
        c = 1'b0;
        check_value("muda a/b");

        // Aqui esta o ponto central do exemplo.
        // Se o DUT for o codigo ruim, o always @(a or b) nao roda quando so c muda.
        c = 1'b1;
        check_value("muda somente c para 1");

        c = 1'b0;
        check_value("muda somente c para 0");

        b = 1'b0;
        check_value("muda b");

        if (errors == 0) begin
            $display("TEST_RESULT: PASS");
        end else begin
            $display("TEST_RESULT: FAIL errors=%0d", errors);
        end

        $finish;
    end

endmodule
