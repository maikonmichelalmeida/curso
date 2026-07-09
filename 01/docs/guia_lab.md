# Guia do Lab 01 - aprendendo o esqueleto do ambiente

Este lab foi refeito para ficar alinhado com os labs Synopsys e com o ambiente
do professor. O objetivo agora nao e comecar por exemplos de erro em
SystemVerilog. O objetivo e entender como um bloco RTL fica organizado para ser
simulado, sintetizado e depois reaproveitado.

Pense neste lab como uma miniatura controlada do ambiente do professor.

## 1. O que voce deve aprender neste lab

Ao final, voce deve conseguir responder:

```text
1. Onde fica o RTL?
2. Onde fica o testbench?
3. Para que serve um filelist?
4. Por que o Makefile da raiz chama outros Makefiles?
5. Onde ficam os arquivos gerados pela simulacao?
6. Onde ficam os relatorios e netlists gerados pela sintese?
7. O que o arquivo SDC esta dizendo para o Design Compiler?
8. O que o Tcl de sintese faz, passo a passo?
```

Essas perguntas sao mais importantes agora do que escrever um processador ou um
testbench sofisticado. O professor esta enfatizando o ambiente e as constraints;
entao o primeiro passo bom e dominar a infraestrutura minima.

## 2. A estrutura do bloco

Entre na pasta:

```bash
cd ~/curso/01
```

Veja a estrutura:

```bash
make show
```

Voce deve enxergar mentalmente isto:

```text
01/
  Makefile
  rtl/
    lab01_top.sv
  verif/
    top_tb.sv
    filelist.f
    filelist_rtl.f
  constraints/
    constraints.sdc
  tools/
    vcs/
      scripts/Makefile
      run/
    dc_nxt/
      scripts/Makefile
      scripts/setup.tcl
      scripts/synth.tcl
      run/
      outputs/
      rpt/
```

A regra central e simples:

```text
codigo humano de entrada       -> rtl, verif, constraints, scripts
arquivos gerados por ferramenta -> run, outputs, rpt
```

Isso evita misturar fonte com lixo de simulacao/sintese.

## 3. Makefile da raiz

Abra:

```bash
less Makefile
```

Este Makefile e parecido com o do professor no papel principal: ele e um
orquestrador. Ele nao chama `vcs` diretamente e nao chama `dcnxt_shell`
diretamente. Ele entra na pasta da ferramenta e delega:

```text
make sim   -> tools/vcs/scripts/Makefile
make synth -> tools/dc_nxt/scripts/Makefile
```

Isso parece burocracia no inicio, mas tem uma vantagem enorme: quando o projeto
cresce, cada ferramenta tem seu proprio lugar.

Rode:

```bash
make help
```

Observe as variaveis:

```text
USE_MODULES
SAED_REF
MODULES
```

### USE_MODULES

Se `USE_MODULES=1`, o Makefile tenta carregar os modulos Synopsys antes de rodar.
Isso imita o ambiente do professor:

```bash
make sim
```

Se voce ja carregou os modulos manualmente, pode evitar o carregamento automatico:

```bash
make sim USE_MODULES=0
```

### SAED_REF

`SAED_REF` aponta para a pasta da biblioteca tecnologica SAED. A sintese precisa
dela porque o DC_NXT nao transforma RTL em "portas abstratas"; ele mapeia o RTL
para celulas reais de uma biblioteca.

Cheque:

```bash
make doctor
```

Se aparecer que `SAED_REF` nao foi encontrado, rode a sintese informando o caminho:

```bash
make synth SAED_REF=/caminho/para/ref
```

O importante e que dentro de `ref` existam subpastas como:

```text
DBs/
CLIBs/
tech/
verilog/
```

## 4. RTL pequeno: lab01_top.sv

Abra:

```bash
less rtl/lab01_top.sv
```

O design e propositalmente pequeno: um contador registrador com `clk`, `rst_n`,
`enable`, `load`, direcao de contagem e flags.

Por que um contador?

Porque ele tem quase tudo que precisamos para treinar o ambiente:

```text
clock
reset
registrador
entrada de controle
entrada de dados
saida de dados
logica combinacional simples
```

O objetivo nao e impressionar no RTL. O objetivo e ter um design pequeno para
enxergar claramente o que VCS, SDC e DC_NXT fazem.

## 5. Testbench e waveform

Abra:

```bash
less verif/top_tb.sv
```

O testbench faz quatro coisas:

```text
1. gera clock;
2. aplica reset;
3. testa load;
4. testa contagem para cima e para baixo.
```

Ele tambem gera waveform FSDB:

```systemverilog
$fsdbDumpfile("top_rtl.fsdb");
$fsdbDumpvars(0, top_tb);
```

No ambiente com Verdi, isso permite abrir a simulacao depois.

## 6. Filelist: o mapa de entrada da ferramenta

Abra:

```bash
less verif/filelist.f
```

O `filelist.f` e uma lista de arquivos para o VCS. Em vez de digitar todos os
arquivos na linha de comando, o Makefile diz:

```bash
vcs -f ../../../verif/filelist.f
```

Dentro do filelist existem:

```text
+incdir+../../../rtl
+incdir+../../../verif
../../../rtl/lab01_top.sv
../../../verif/top_tb.sv
```

Essa estrutura vem dos labs Synopsys e do ambiente do professor.

Tambem existe:

```bash
less verif/filelist_rtl.f
```

Esse segundo filelist e usado pela sintese. Ele contem apenas o design, sem o
testbench. Isso deixa o fluxo mais didatico: VCS ve design + testbench; DC_NXT
ve apenas design sintetizavel.

## 7. Rodando simulacao RTL

Rode:

```bash
make sim
```

O caminho executado e:

```text
Makefile da raiz
  -> tools/vcs/scripts/Makefile
     -> cria tools/vcs/run
     -> entra em tools/vcs/run
     -> chama vcs
     -> executa ./simv
```

Veja os arquivos gerados:

```bash
ls tools/vcs/run
```

Arquivos importantes:

```text
vcs_compile.log  log da compilacao
vcs_run.log      log da simulacao
simv             executavel gerado pelo VCS
top_rtl.fsdb     waveform para o Verdi
```

Leia o log:

```bash
less tools/vcs/run/vcs_run.log
```

Procure:

```text
TEST_RESULT: PASS
```

## 8. Abrindo waveform

Depois da simulacao:

```bash
make waves
```

No Verdi, observe primeiro estes sinais:

```text
clk
rst_n
enable
load
up
load_value
count
at_zero
at_max
```

Nao tente olhar tudo de uma vez. A ordem boa e:

```text
1. reset coloca count em zero?
2. load carrega 8'h3c?
3. enable=1 e up=1 incrementa?
4. up=0 decrementa?
5. at_zero e at_max fazem sentido?
```

## 9. Constraints: o primeiro contato com SDC

Abra:

```bash
less constraints/constraints.sdc
```

Este arquivo e o ponto mais importante do lab para a fala do professor.

RTL descreve o circuito. SDC descreve o contexto em que o circuito precisa
funcionar.

Neste lab, o SDC informa:

```text
1. existe um clock chamado core_clk no pino clk;
2. o periodo do clock e 10 ns;
3. existe incerteza de clock;
4. entradas chegam depois de certa margem;
5. saidas precisam ficar prontas antes de certa margem;
6. as saidas enxergam uma carga;
7. reset nao deve ser tratado como caminho normal de timing.
```

Sem constraints, o sintetizador ate consegue mapear logica, mas nao sabe qual e
a meta de timing. Com constraints, ele sabe o "contrato" que deve tentar cumprir.

## 10. Setup do DC_NXT

Abra:

```bash
less tools/dc_nxt/scripts/setup.tcl
```

Esse arquivo configura caminhos e bibliotecas:

```text
DESIGN_NAME       nome do top sintetizado
RTL_FILELIST      lista de RTL para a sintese
SDC_FILE          constraints
SAED_REF          raiz da biblioteca SAED
target_library    celulas que o DC_NXT pode escolher
link_library      bibliotecas para resolver referencias
search_path       onde procurar arquivos
```

Essa separacao e proposital:

```text
setup.tcl  -> onde estao as coisas
synth.tcl  -> o que fazer com essas coisas
```

## 11. Fluxo de sintese

Abra:

```bash
less tools/dc_nxt/scripts/synth.tcl
```

O fluxo e curto:

```text
1. source setup.tcl
2. analyze RTL
3. elaborate top
4. link com biblioteca
5. check_design
6. source constraints.sdc
7. check_timing
8. compile_ultra
9. gerar relatorios
10. exportar netlist, ddc, sdc final e sdf
```

Esse e o coracao do que voce precisa entender antes de brincar com constraints.

## 12. Rodando sintese

Primeiro cheque:

```bash
make doctor
```

Se a biblioteca estiver correta:

```bash
make synth
```

Se precisar informar o caminho:

```bash
make synth SAED_REF=/caminho/para/ref
```

Depois veja:

```bash
ls tools/dc_nxt/run
ls tools/dc_nxt/rpt
ls tools/dc_nxt/outputs
```

Arquivos importantes:

```text
tools/dc_nxt/run/dc_synth.log
tools/dc_nxt/rpt/lab01_top_area.rpt
tools/dc_nxt/rpt/lab01_top_timing.rpt
tools/dc_nxt/rpt/lab01_top_qor.rpt
tools/dc_nxt/outputs/lab01_top_mapped.v
tools/dc_nxt/outputs/lab01_top_final.sdc
tools/dc_nxt/outputs/lab01_top_delays.sdf
```

## 13. O que observar nos relatorios

Comece por:

```bash
less tools/dc_nxt/rpt/lab01_top_qor.rpt
less tools/dc_nxt/rpt/lab01_top_timing.rpt
less tools/dc_nxt/rpt/lab01_top_area.rpt
```

Perguntas:

```text
1. A sintese terminou sem erro?
2. O DC_NXT encontrou a biblioteca?
3. O clock core_clk apareceu no timing?
4. Existe violacao de timing?
5. Quantas celulas foram usadas?
6. A netlist mapeada tem celulas SAED?
```

Abra a netlist:

```bash
less tools/dc_nxt/outputs/lab01_top_mapped.v
```

Voce deve ver que o RTL comportamental virou instancias de celulas.

## 14. Ordem cronologica recomendada

Use esta ordem na primeira execucao:

```bash
cd ~/curso/01
make help
make show
make doctor

less rtl/lab01_top.sv
less verif/filelist.f
less verif/top_tb.sv
make sim
less tools/vcs/run/vcs_run.log
make waves

less constraints/constraints.sdc
less tools/dc_nxt/scripts/setup.tcl
less tools/dc_nxt/scripts/synth.tcl
make synth
less tools/dc_nxt/run/dc_synth.log
less tools/dc_nxt/rpt/lab01_top_timing.rpt
less tools/dc_nxt/outputs/lab01_top_mapped.v
```

## 15. Como este lab prepara o proximo passo

Depois deste lab, o proximo passo nao deve ser criar um exemplo aleatorio de
erro. O proximo passo deve ser mexer em uma variavel do ambiente e observar o
efeito.

Boas experiencias para o Lab 02:

```text
1. mudar o periodo do clock no SDC;
2. comparar relatorio de timing com clock relaxado e clock apertado;
3. observar area, power e timing;
4. gerar uma simulacao gate-level simples;
5. so depois introduzir exemplos ruins/corretos de RTL.
```

Assim voce aprende do jeito que o professor parece estar pedindo: primeiro o
ambiente, depois constraints, depois experimentos controlados.
