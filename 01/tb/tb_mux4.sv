// =============================================================================
// Lab 01 - Testbench do mux 4:1
// =============================================================================
//
// Este testbench e propositalmente direto.
// Ele nao usa classe, interface, driver, monitor nem scoreboard.
//
// A meta aqui e lembrar o basico:
// - instanciar o DUT;
// - aplicar estimulos;
// - conferir a saida;
// - gerar waveform para o Verdi.

module tb_mux4;

    localparam int WIDTH = 8;

    logic [WIDTH-1:0] d0;
    logic [WIDTH-1:0] d1;
    logic [WIDTH-1:0] d2;
    logic [WIDTH-1:0] d3;
    logic [1:0]       sel;
    logic [WIDTH-1:0] y;

    // DUT significa Design Under Test, ou seja, o circuito testado.
    mux4 #(
        .WIDTH(WIDTH)
    ) dut (
        .d0  (d0),
        .d1  (d1),
        .d2  (d2),
        .d3  (d3),
        .sel (sel),
        .y   (y)
    );

    // Estas chamadas geram o arquivo de onda que sera aberto no Verdi.
    // O nome escolhido aparece tambem no Makefile.
    initial begin
        $fsdbDumpfile("mux4.fsdb");
        $fsdbDumpvars(0, tb_mux4);
    end

    // Tarefa pequena para evitar repetir o mesmo if quatro vezes.
    // Primeiro mudamos sel, esperamos 1 ns e depois conferimos y.
    task automatic verifica_mux(
        input logic [1:0]       sel_teste,
        input logic [WIDTH-1:0] valor_esperado
    );
        begin
            sel = sel_teste;
            #1ns;

            if (y !== valor_esperado) begin
                $display("ERRO: sel=%0d esperado=0x%0h obtido=0x%0h",
                         sel_teste, valor_esperado, y);
                $display("TEST_RESULT: FAIL");
                $finish;
            end else begin
                $display("OK: sel=%0d y=0x%0h", sel_teste, y);
            end
        end
    endtask

    initial begin
        // Valores diferentes ajudam a enxergar rapidamente na waveform
        // qual entrada foi selecionada.
        d0  = 8'ha0;
        d1  = 8'hb1;
        d2  = 8'hc2;
        d3  = 8'hd3;
        sel = 2'b00;

        verifica_mux(2'b00, d0);
        verifica_mux(2'b01, d1);
        verifica_mux(2'b10, d2);
        verifica_mux(2'b11, d3);

        $display("TEST_RESULT: PASS");
        $finish;
    end

endmodule
