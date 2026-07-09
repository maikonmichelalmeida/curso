`timescale 1ns/1ps

module tb_03_fsm;

    logic clk;
    logic rst_n;
    logic start;
    logic done;
    logic busy;
    logic [1:0] state_dbg;
    int errors;

    fsm_dut dut (
        .clk       (clk),
        .rst_n     (rst_n),
        .start     (start),
        .done      (done),
        .busy      (busy),
        .state_dbg (state_dbg)
    );

    always #5 clk = ~clk;

    task automatic check_state(
        input string label,
        input logic [1:0] expected_state,
        input logic expected_busy
    );
        begin
            #1;
            $display("T=%0t %-28s state=%0d busy=%0b expected_state=%0d expected_busy=%0b",
                     $time, label, state_dbg, busy, expected_state, expected_busy);

            if ((state_dbg !== expected_state) || (busy !== expected_busy)) begin
                errors++;
                $display("  OBSERVE: comportamento funcional inesperado.");
            end
        end
    endtask

    initial begin
        $fsdbDumpfile("wave.fsdb");
        $fsdbDumpvars(0, tb_03_fsm);

        clk = 1'b0;
        rst_n = 1'b0;
        start = 1'b0;
        done = 1'b0;
        errors = 0;

        $display("============================================================");
        $display("EX03 - FSM fragil vs FSM robusta");
        $display("O CASE=bad pode parecer funcionar, mas a sintese deve denunciar");
        $display("estrutura perigosa: next_state sem atribuicao em todos os caminhos.");
        $display("============================================================");

        repeat (2) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);
        check_state("apos reset", 2'd0, 1'b0);

        start = 1'b1;
        @(posedge clk);
        start = 1'b0;
        check_state("entra em WORK", 2'd1, 1'b1);

        done = 1'b0;
        repeat (2) begin
            @(posedge clk);
            check_state("fica em WORK", 2'd1, 1'b1);
        end

        done = 1'b1;
        @(posedge clk);
        done = 1'b0;
        check_state("vai para DONE", 2'd2, 1'b0);

        @(posedge clk);
        check_state("volta para IDLE", 2'd0, 1'b0);

        if (errors == 0) begin
            $display("TEST_RESULT: PASS");
            $display("OBSERVE: se CASE=bad passou na simulacao, ainda assim leia os logs de sintese.");
        end else begin
            $display("TEST_RESULT: FAIL errors=%0d", errors);
        end

        $finish;
    end

endmodule
