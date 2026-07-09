// =============================================================================
// Lab 01 - RTL minimo para exercitar o ambiente
// =============================================================================
//
// Este modulo e pequeno de proposito. A primeira aula do ambiente nao deve
// esconder a infraestrutura atras de um design grande.
//
// O bloco contem os elementos que quase todo fluxo RTL precisa enxergar:
// - clock;
// - reset;
// - registrador;
// - controle;
// - entradas e saidas;
// - logica combinacional simples.

module lab01_top #(
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             rst_n,
    input  logic             enable,
    input  logic             load,
    input  logic             up,
    input  logic [WIDTH-1:0] load_value,
    output logic [WIDTH-1:0] count,
    output logic             at_zero,
    output logic             at_max
);

    // Processo sequencial: tudo que depende de borda de clock fica aqui.
    // Esta separacao ajuda o simulador, a sintese e o leitor humano.
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            count <= '0;
        end else if (load) begin
            count <= load_value;
        end else if (enable) begin
            if (up) begin
                count <= count + {{(WIDTH-1){1'b0}}, 1'b1};
            end else begin
                count <= count - {{(WIDTH-1){1'b0}}, 1'b1};
            end
        end
    end

    // Logica combinacional continua. Estas flags nao guardam estado; elas
    // apenas refletem o valor atual do registrador count.
    assign at_zero = (count == '0);
    assign at_max  = (count == {WIDTH{1'b1}});

endmodule
