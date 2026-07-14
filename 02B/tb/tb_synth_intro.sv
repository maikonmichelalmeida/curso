// =============================================================================
// Lab 02B - testbench minimo do synth_intro
// =============================================================================
//
// Este testbench responde somente a pergunta funcional:
//
//   "O RTL registra as entradas, soma os valores registrados e registra o
//    resultado no ciclo seguinte?"
//
// Ele nao entra na sintese. O Design Compiler recebera apenas
// ../rtl/synth_intro.sv. Testbench pode usar atrasos, $display e FSDB porque
// existe para estimular e observar o hardware, nao para virar portas logicas.
//
// O periodo usado aqui e 10 ns:
//
//   always #5 clk = ~clk;
//
// Isso combina com o create_clock -period 10 usado mais tarde. Simulacao e
// constraint continuam sendo coisas diferentes: o atraso gera bordas na
// simulacao; create_clock descreve uma exigencia temporal para a sintese.

`timescale 1ns/1ps

module tb_synth_intro;

    logic       clk;
    logic       rst;
    logic       enable;
    logic [7:0] a;
    logic [7:0] b;
    logic [8:0] result;

    int errors;

    synth_intro dut (
        .clk    (clk),
        .rst    (rst),
        .enable (enable),
        .a      (a),
        .b      (b),
        .result (result)
    );

    // Uma inversao a cada 5 ns produz um periodo completo de 10 ns.
    initial clk = 1'b0;
    always #5 clk = ~clk;

    initial begin
        // O FSDB permite abrir a execucao no Verdi depois da simulacao.
        $fsdbDumpfile("synth_intro.fsdb");
        $fsdbDumpvars(0, tb_synth_intro);

        errors = 0;
        rst = 1'b1;
        enable = 1'b0;
        a = 8'd0;
        b = 8'd0;

        // Mantemos o reset por duas bordas. Como ele e sincrono, apenas
        // esperar tempo nao basta: precisamos realmente atravessar posedges.
        repeat (2) @(posedge clk);
        #1;

        if (result !== 9'd0) begin
            $error("Reset falhou: result=%0d, esperado=0", result);
            errors++;
        end

        // Aplicamos 10 e 7 na borda de descida para que os sinais fiquem
        // estaveis antes da proxima borda de subida.
        @(negedge clk);
        rst = 1'b0;
        enable = 1'b1;
        a = 8'd10;
        b = 8'd7;

        // Primeira borda com enable: a_q e b_q capturam 10 e 7. result ainda
        // enxerga os valores antigos dos registradores de entrada, ambos zero.
        @(posedge clk);
        #1;

        if (dut.a_q !== 8'd10 || dut.b_q !== 8'd7) begin
            $error("Estagio de entrada falhou: a_q=%0d b_q=%0d", dut.a_q, dut.b_q);
            errors++;
        end

        if (result !== 9'd0) begin
            $error("Latencia inesperada: result=%0d, esperado=0", result);
            errors++;
        end

        // Preparamos um segundo par. Na proxima borda, result deve receber
        // 10 + 7, enquanto a_q e b_q passam a guardar 20 e 3.
        @(negedge clk);
        a = 8'd20;
        b = 8'd3;

        @(posedge clk);
        #1;

        if (result !== 9'd17) begin
            $error("Primeira soma falhou: result=%0d, esperado=17", result);
            errors++;
        end

        // Mais uma borda deixa visivel a soma do segundo par: 20 + 3 = 23.
        @(negedge clk);
        a = 8'd1;
        b = 8'd1;

        @(posedge clk);
        #1;

        if (result !== 9'd23) begin
            $error("Segunda soma falhou: result=%0d, esperado=23", result);
            errors++;
        end

        // Com enable em zero, nenhum dos 25 bits registrados deve mudar.
        @(negedge clk);
        enable = 1'b0;
        a = 8'd200;
        b = 8'd100;

        @(posedge clk);
        #1;

        if (result !== 9'd23) begin
            $error("Hold com enable=0 falhou: result=%0d, esperado=23", result);
            errors++;
        end

        if (errors == 0) begin
            $display("LAB02B PASS: pipeline, soma, reset e enable funcionaram.");
        end else begin
            $fatal(1, "LAB02B FAIL: foram encontrados %0d erros.", errors);
        end

        $finish;
    end

endmodule
