# Mapa de erros do Lab 01

| Erro | Arquivo ruim | Arquivo correto | Tecnica correta | Principal observacao |
| --- | --- | --- | --- | --- |
| 01 | `rtl/01_sensitivity_bad.sv` | `rtl/01_sensitivity_good.sv` | `always_comb` | RTL sim pode divergir da sintese |
| 02 | `rtl/02_latch_bad.sv` | `rtl/02_latch_good.sv` | default em `always_comb` | falta de atribuicao infere latch |
| 03 | `rtl/03_fsm_bad.sv` | `rtl/03_fsm_good.sv` | `enum`, `always_ff`, `always_comb`, default | TB pode passar, mas RTL continua ruim |

## Regra pratica

Se for combinacional:

```systemverilog
always_comb begin
    saida = default;
    ...
end
```

Se for registrador/estado:

```systemverilog
always_ff @(posedge clk or negedge rst_n) begin
    ...
end
```

Se for FSM:

```systemverilog
typedef enum logic [N:0] { ... } state_t;
state_t state, next_state;
```

E no bloco combinacional:

```systemverilog
next_state = state;
unique case (state)
    ...
    default: next_state = ST_IDLE;
endcase
```
