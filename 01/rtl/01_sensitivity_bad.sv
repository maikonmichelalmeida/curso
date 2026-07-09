// ==============================================================================
// ERRO 01 - sensitivity list incompleta
// ==============================================================================
//
// Intencao do circuito:
//   y = (a & b) | c
//
// Problema:
//   Este codigo usa always @(a or b), esquecendo o sinal c.
//
// Efeito em simulacao RTL:
//   Se somente c mudar, o bloco always nao executa. A saida y pode ficar velha.
//
// Efeito em sintese:
//   O sintetizador normalmente ignora a lista de sensibilidade e entende a
//   expressao completa. A netlist sintetizada usa a, b e c.
//
// Resultado didatico:
//   A simulacao RTL ruim pode discordar da simulacao gate-level.
//   Isso e o classico "simulation/synthesis mismatch" do guia do lab.

module sensitivity_dut (
    input  logic clk,
    input  logic a,
    input  logic b,
    input  logic c,
    output logic y
);

    // clk esta presente para manter a interface parecida com blocos reais de RTL
    // e permitir o uso do mesmo arquivo SDC. Ele nao deveria afetar esta logica.

    // ERRADO: c e lido dentro do bloco, mas nao esta na lista.
    always @(a or b) begin
        y = (a & b) | c;
    end

endmodule
