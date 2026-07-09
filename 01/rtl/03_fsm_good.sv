// ==============================================================================
// ERRO 03 corrigido - FSM com enum, always_ff e always_comb
// ==============================================================================
//
// Melhorias:
//   1. typedef enum documenta os estados.
//   2. always_ff deixa claro qual bloco e sequencial.
//   3. always_comb deixa claro qual bloco e combinacional.
//   4. next_state = state cria um default seguro.
//   5. unique case ajuda a ferramenta a checar cobertura dos estados.

module fsm_dut (
    input  logic       clk,
    input  logic       rst_n,
    input  logic       start,
    input  logic       done,
    output logic       busy,
    output logic [1:0] state_dbg
);

    typedef enum logic [1:0] {
        ST_IDLE = 2'b00,
        ST_WORK = 2'b01,
        ST_DONE = 2'b10
    } state_t;

    state_t state;
    state_t next_state;

    assign state_dbg = state;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= ST_IDLE;
        end else begin
            state <= next_state;
        end
    end

    always_comb begin
        next_state = state;
        busy       = 1'b0;

        unique case (state)
            ST_IDLE: begin
                if (start) begin
                    next_state = ST_WORK;
                end
            end

            ST_WORK: begin
                busy = 1'b1;
                if (done) begin
                    next_state = ST_DONE;
                end
            end

            ST_DONE: begin
                next_state = ST_IDLE;
            end

            default: begin
                next_state = ST_IDLE;
                busy       = 1'b0;
            end
        endcase
    end

endmodule
