# Guia do Lab 01 - SystemVerilog RTL: mismatch, latch e FSM

Este guia e a ordem de estudo. Os codigos e Tcl tem comentarios detalhados.
Aqui o foco e dizer quando rodar, o que observar e onde procurar a explicacao.

## 0. Ideia do lab

Este lab foi criado a partir do direcionamento dos cursos:

- SystemVerilog for RTL Design;
- RTL Design Synthesis;
- conceitos iniciais de VCS, Verdi e Design Compiler.

O objetivo e construir intuicao antes de mexer no ambiente maior do professor.

Voce vai estudar tres erros classicos:

```text
ERRO 01 - sensitivity list incompleta
ERRO 02 - latch nao intencional
ERRO 03 - FSM fragil, sem estrutura robusta
```

Cada erro tem duas variantes:

```text
CASE=bad   exemplo perigoso
CASE=good  exemplo corrigido
```

O mais importante nao e "passar o teste". O mais importante e entender:

- o que o simulador viu;
- o que a sintese viu;
- por que o log acusa determinado problema;
- por que o codigo correto comunica melhor a intencao.

## 1. Preparacao no servidor

Entre na pasta:

```bash
cd ~/curso/01
```

Se as ferramentas ainda nao estiverem carregadas, carregue os modulos do seu
ambiente. No ambiente do professor apareceu algo deste tipo:

```bash
module load syn/W-2024.09-SP5-2 \
            designcompiler/W-2024.09-SP5-4 \
            vcs/W-2024.09-SP2-3 \
            verdi/W-2024.09-SP2-6
```

Se os nomes mudarem no servidor, use os modulos equivalentes disponiveis.

Veja os comandos:

```bash
make help
```

Cheque ferramentas:

```bash
make doctor
```

O `doctor` deve encontrar pelo menos:

- `vcs`;
- `verdi`;
- `dc_shell`;
- biblioteca SAED em `SAED_REF`.

Se a biblioteca nao estiver no caminho default, rode com:

```bash
make doctor SAED_REF=/caminho/para/ref
```

Depois repita os outros comandos usando o mesmo `SAED_REF=...`.

## 2. ERRO 01 - sensitivity list incompleta

Arquivos principais:

```text
rtl/01_sensitivity_bad.sv
rtl/01_sensitivity_good.sv
tb/tb_01_sensitivity.sv
```

Leia primeiro:

```bash
less rtl/01_sensitivity_bad.sv
less rtl/01_sensitivity_good.sv
less tb/tb_01_sensitivity.sv
```

### 2.1 Simule o codigo ruim

```bash
make sim EX=01 CASE=bad
```

O que observar no log:

```bash
less logs/01_bad/vcs_run.log
```

Procure o trecho em que o testbench muda somente `c`.

O esperado pelo circuito e:

```systemverilog
y = (a & b) | c;
```

Mas no codigo ruim:

```systemverilog
always @(a or b)
```

O sinal `c` foi esquecido na lista de sensibilidade.

Resultado esperado:

```text
TEST_RESULT: FAIL
```

Isso e bom para estudo: o erro foi revelado.

### 2.2 Abra a waveform

```bash
make waves EX=01 CASE=bad
```

Observe:

- `c` muda;
- `a` e `b` nao mudam;
- `y` nao atualiza no momento correto.

### 2.3 Simule o codigo correto

```bash
make sim EX=01 CASE=good
```

Agora o codigo usa:

```systemverilog
always_comb
```

Resultado esperado:

```text
TEST_RESULT: PASS
```

### 2.4 Sintetize as duas versoes

```bash
make synth EX=01 CASE=bad
make synth EX=01 CASE=good
```

O que observar:

```bash
less logs/01_bad/dc_synth.log
less logs/01_good/dc_synth.log
less outputs/01_bad/sensitivity_dut_mapped.v
less outputs/01_good/sensitivity_dut_mapped.v
```

Ponto central:

O sintetizador tende a implementar a expressao completa usando `a`, `b` e `c`,
mesmo que a simulacao RTL ruim nao atualize quando `c` muda sozinho.

Essa e a ideia de mismatch entre simulacao e sintese.

### 2.5 Simule gate-level

Depois da sintese:

```bash
make gate EX=01 CASE=bad
make gate EX=01 CASE=good
```

Compare:

```bash
less logs/01_bad/vcs_run.log
less logs/01_bad/gate_run.log
```

Pergunta para voce responder:

```text
A simulacao RTL ruim falhou, mas a gate-level passou?
Se sim, por que isso prova mismatch?
```

## 3. ERRO 02 - latch nao intencional

Arquivos:

```text
rtl/02_latch_bad.sv
rtl/02_latch_good.sv
tb/tb_02_latch.sv
```

Leia:

```bash
less rtl/02_latch_bad.sv
less rtl/02_latch_good.sv
```

### 3.1 Simule o codigo ruim

```bash
make sim EX=02 CASE=bad
```

Observe:

```bash
less logs/02_bad/vcs_run.log
```

Ponto central:

Quando `sel=0`, o codigo ruim nao atribui `y`.

Entao `y` retem o valor anterior. Esse "reter valor" nao e combinacional puro:
isso e comportamento de latch.

### 3.2 Simule o codigo correto

```bash
make sim EX=02 CASE=good
```

No codigo correto, existe default:

```systemverilog
y = 1'b0;
```

Depois o `if (sel)` sobrescreve quando necessario.

### 3.3 Sintetize e procure latch

```bash
make synth EX=02 CASE=bad
make synth EX=02 CASE=good
```

Leia:

```bash
less logs/02_bad/dc_synth.log
less rpt/02_bad/latch_dut_check_design_post.rpt
less outputs/02_bad/latch_dut_mapped.v
```

O que procurar:

- mensagens sobre latch;
- celulas de latch na netlist;
- diferenca entre `bad` e `good`.

Pergunta:

```text
O erro apareceu na simulacao, na sintese ou nos dois?
```

## 4. ERRO 03 - FSM fragil

Arquivos:

```text
rtl/03_fsm_bad.sv
rtl/03_fsm_good.sv
tb/tb_03_fsm.sv
```

Leia:

```bash
less rtl/03_fsm_bad.sv
less rtl/03_fsm_good.sv
```

### 4.1 Simule o codigo ruim

```bash
make sim EX=03 CASE=bad
```

Esse caso pode passar na simulacao.

Isso e proposital.

Licao:

```text
Nem todo problema de qualidade RTL aparece como erro funcional no testbench.
```

### 4.2 Simule o codigo correto

```bash
make sim EX=03 CASE=good
```

Observe no codigo correto:

```systemverilog
typedef enum logic [1:0]
always_ff
always_comb
next_state = state;
unique case
default
```

Esses elementos deixam a intencao mais clara para humano, simulador e sintese.

### 4.3 Sintetize e compare logs

```bash
make synth EX=03 CASE=bad
make synth EX=03 CASE=good
```

Leia:

```bash
less logs/03_bad/dc_synth.log
less logs/03_good/dc_synth.log
less rpt/03_bad/fsm_dut_check_design_post.rpt
less rpt/03_good/fsm_dut_check_design_post.rpt
```

O que observar:

- `bad` tem caminhos sem atribuicao de `next_state`;
- `good` usa default seguro;
- `enum` facilita leitura;
- `always_ff` separa sequencial;
- `always_comb` separa combinacional.

## 5. Ordem recomendada completa

Rode nesta ordem:

```bash
make sim EX=01 CASE=bad
make sim EX=01 CASE=good
make synth EX=01 CASE=bad
make synth EX=01 CASE=good
make gate EX=01 CASE=bad
make gate EX=01 CASE=good

make sim EX=02 CASE=bad
make sim EX=02 CASE=good
make synth EX=02 CASE=bad
make synth EX=02 CASE=good

make sim EX=03 CASE=bad
make sim EX=03 CASE=good
make synth EX=03 CASE=bad
make synth EX=03 CASE=good
```

## 6. O que anotar no seu caderno

Para cada erro, anote:

```text
1. Qual era a intencao do hardware?
2. Qual linha do codigo ruim nao comunica essa intencao?
3. A simulacao RTL falhou?
4. A sintese mostrou warning ou inferiu algo perigoso?
5. O codigo correto resolve com qual tecnica?
6. Como isso se aplica ao meu projeto maior?
```

## 7. Ponte para o ambiente do professor

Depois deste lab, o proximo passo natural e revisar o bloco `RTL_LAB2` no
ambiente do professor procurando:

- listas de sensibilidade antigas;
- combinacional sem default;
- FSM sem `enum`;
- mistura de sequencial e combinacional;
- pontos onde RTL e gate-level poderiam divergir;
- constraints basicas para DC NXT.

Este lab e pequeno de proposito. Ele prepara sua cabeca para entender melhor
o que o professor quer quando fala de usar o ambiente, mexer em constraints
e observar as ferramentas.
