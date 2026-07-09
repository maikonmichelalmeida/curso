// =============================================================================
// Lab 01 - Testbench simples
// =============================================================================
//
// Este testbench nao usa UVM. O objetivo e deixar claro o fluxo basico:
// VCS compila design + testbench, roda a simulacao e gera waveform FSDB.

module top_tb;

    localparam int WIDTH = 8;
    localparam time CLK_PERIOD = 10ns;

    logic             clk;
    logic             rst_n;
    logic             enable;
    logic             load;
    logic             up;
    logic [WIDTH-1:0] load_value;
    logic [WIDTH-1:0] count;
    logic             at_zero;
    logic             at_max;

    lab01_top #(
        .WIDTH(WIDTH)
    ) dut (
        .clk        (clk),
        .rst_n      (rst_n),
        .enable     (enable),
        .load       (load),
        .up         (up),
        .load_value (load_value),
        .count      (count),
        .at_zero    (at_zero),
        .at_max     (at_max)
    );

    initial begin
        clk = 1'b0;
        forever #(CLK_PERIOD/2) clk = ~clk;
    end

    initial begin
        $fsdbDumpfile("top_rtl.fsdb");
        $fsdbDumpvars(0, top_tb);
    end

    task automatic check_count(input logic [WIDTH-1:0] expected, input string step_name);
        if (count !== expected) begin
            $error("FAIL %s: expected count=0x%0h observed count=0x%0h",
                   step_name, expected, count);
            $display("TEST_RESULT: FAIL");
            $finish;
        end
    endtask

    task automatic wait_clock();
        @(posedge clk);
        #1ps;
    endtask

    initial begin
        rst_n      = 1'b0;
        enable     = 1'b0;
        load       = 1'b0;
        up         = 1'b1;
        load_value = '0;

        repeat (3) @(posedge clk);
        rst_n = 1'b1;
        wait_clock();
        check_count(8'h00, "after reset");

        load_value = 8'h3c;
        load       = 1'b1;
        wait_clock();
        check_count(8'h3c, "after load");
        load       = 1'b0;

        enable = 1'b1;
        up     = 1'b1;
        wait_clock();
        check_count(8'h3d, "count up 1");
        wait_clock();
        check_count(8'h3e, "count up 2");

        up = 1'b0;
        wait_clock();
        check_count(8'h3d, "count down 1");
        wait_clock();
        check_count(8'h3c, "count down 2");

        enable = 1'b0;
        repeat (2) @(posedge clk);
        #1ps;
        check_count(8'h3c, "hold when enable is zero");

        $display("TEST_RESULT: PASS");
        $finish;
    end

endmodule
