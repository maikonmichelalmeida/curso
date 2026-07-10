// =============================================================================
// Lab 03 - ALU combinacional didatica
// =============================================================================
//
// Este arquivo e uma versao comentada da ALU que voce criou no Lab 02.
// A intencao aqui nao e inventar uma ALU nova, mas reaproveitar o bloco
// combinacional que voce ja conhece e coloca-lo dentro de um fluxo de
// constraints e sintese.
//
// Papel desta ALU no Lab 03:
//
//   1. Receber dois operandos vindos de registradores.
//   2. Fazer uma operacao puramente combinacional.
//   3. Entregar o resultado para um registrador de saida no mini_datapath.
//
// Isso cria o caminho classico de estudo de timing:
//
//   registrador_origem -> ALU combinacional -> registrador_destino
//
// Quando aplicarmos create_clock, a ferramenta vai perguntar implicitamente:
// "a logica entre esses registradores cabe dentro do periodo de clock?"
//
// Por isso este modulo e propositalmente simples. O foco nao e arquitetura de
// processador. O foco e enxergar como uma pequena logica combinacional afeta
// timing, area e relatorios de sintese.

module alu #(
    parameter int unsigned WIDTH = 8
) (
    input  logic [WIDTH-1:0]   in1,
    input  logic [WIDTH-1:0]   in2,
    input  logic [2:0]         op,
    input  logic               invalid_data,
    output logic [2*WIDTH-1:0] out,
    output logic               zero,
    output logic               error
);

    localparam logic [2:0] OP_ADD = 3'b000;
    localparam logic [2:0] OP_SUB = 3'b001;
    localparam logic [2:0] OP_MUL = 3'b010;
    localparam logic [2:0] OP_DIV = 3'b011;

    always_comb begin
        // Valores padrao em bloco combinacional.
        //
        // Este padrao e muito importante para sintese:
        //
        //   - toda saida recebe valor em todo caminho;
        //   - evitamos latch nao intencional;
        //   - a ferramenta entende que queremos apenas logica combinacional.
        //
        // No Lab 04 da Synopsys ha exercicios sobre latch nao intencional.
        // Aqui ja seguimos o estilo seguro desde o inicio.
        out   = '0;
        zero  = 1'b0;
        error = 1'b0;

        if (invalid_data) begin
            out   = '1;
            error = 1'b1;
        end else begin
            case (op)
                OP_ADD: out = {{WIDTH{1'b0}}, in1} + {{WIDTH{1'b0}}, in2};
                OP_SUB: out = {{WIDTH{1'b0}}, in1} - {{WIDTH{1'b0}}, in2};

                // Multiplicacao e uma operacao interessante para constraints.
                // Ela costuma gerar uma logica maior que soma/subtracao. Com
                // clock apertado, e um bom candidato a aparecer como caminho
                // critico no report_timing.
                OP_MUL: out = in1 * in2;

                // Divisao foi mantida porque existia na sua ALU original.
                // Em sintese real, divisao combinacional pode ser cara. Para
                // estudo isso e util: ela mostra que uma linha simples de RTL
                // pode virar hardware pesado. Se os relatorios ficarem ruins,
                // voce ja tera um exemplo concreto do motivo.
                OP_DIV: begin
                    if (in2 == '0) begin
                        out   = '1;
                        error = 1'b1;
                    end else begin
                        out = {{WIDTH{1'b0}}, in1} / {{WIDTH{1'b0}}, in2};
                    end
                end

                default: out = '0;
            endcase

            if (!error) begin
                zero = (out == '0);
            end
        end
    end

endmodule
