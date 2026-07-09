// ==============================================================================
// ERRO 03 - FSM fragil
// ==============================================================================
//
// Intencao:
//   IDLE -> WORK quando start=1.
//   WORK -> DONE quando done=1.
//   DONE -> IDLE automaticamente.
//
// Problemas didaticos:
//   1. Estados sao numeros soltos, menos autoexplicativos.
//   2. Bloco combinacional nao atribui next_state em todos os caminhos.
//   3. Falta default antes do case.
//   4. Falta default no case.
//
// Efeito:
//   Pode inferir latch em next_state.
//   Pode simular "parecendo funcionar", mas a sintese/logs denunciam estrutura
//   perigosa. Esse e um ponto importante: nem todo problema aparece no TB.

module fsm_dut (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic       done,
    output logic       busy,
    output logic [1:0] state_dbg
);

    localparam logic [1:0] IDLE = 2'b00;
    localparam logic [1:0] WORK = 2'b01;
    localparam logic [1:0] DONE = 2'b10;

    logic [1:0] state;
    logic [1:0] next_state;

    assign state_dbg = state;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // ERRADO: estrutura combinacional incompleta.
    always @(*) begin
        busy = 1'b0;

        case (state)
            IDLE: begin
                if (start) begin
                    next_state = WORK;
                end else begin
                    next_state = IDLE;
                end
            end

            WORK: begin
                busy = 1'b1;
                if (done) begin
                    next_state = DONE;
                end
                // ERRADO:
                // Quando done=0, next_state nao recebe valor.
                // Para "lembrar" o valor anterior, a sintese pode inferir latch.
            end

            DONE: begin
                next_state = IDLE;
            end

            // ERRADO:
            // Sem default. Se state tiver valor invalido, next_state fica sem
            // atribuicao clara.
        endcase
    end

endmodule
