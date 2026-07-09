# Guia do Lab 01 - primeiro passo com o lab SystemVerilog

Este lab agora segue a direcao correta: pequeno, gradual e baseado no laboratorio
de SystemVerilog do curso.

Nesta primeira etapa voce nao vai configurar sintese, constraints ou Tcl. Voce
vai apenas rodar uma simulacao SystemVerilog que ja vem do material Synopsys e
entender a organizacao minima.

## 1. Estrutura que voce deve observar

```text
01/
  rtl/
    reg_array.sv
  simulation/
    Makefile
    reg_array.f
    reg_if.v
    transaction_object.sv
    Driver.sv
    Monitor.sv
    scoreboard.sv
    env.sv
    test.sv
    tb.v
```

O que importa agora:

```text
rtl/         contem o design que sera testado
simulation/  contem testbench, classes de verificacao, filelist e Makefile
```

Esse e o primeiro esqueleto. Ele ainda nao e o ambiente do professor completo.
E so a primeira camada.

## 2. O design: reg_array.sv

Abra:

```bash
cd ~/curso/01
less rtl/reg_array.sv
```

O modulo principal e `reg_ctrl`. Ele representa um pequeno banco de registradores
controlado por uma interface.

Observe sem tentar decorar:

```text
reg_if _if
parameter ADDR_WIDTH
parameter DATA_WIDTH
parameter DEPTH
parameter RESET_VAL
ctrl[DEPTH]
ready
wr
addr
wdata
rdata
```

A ideia funcional e:

```text
se reset esta ativo:
    inicializa a memoria interna com RESET_VAL
senao, se for escrita valida:
    grava wdata no endereco addr
senao, se for leitura valida:
    devolve ctrl[addr] em rdata
```

Esse design e pequeno, mas ja mostra uma coisa importante do curso: o DUT pode
ser ligado ao testbench por uma `interface`.

## 3. A interface: reg_if.v

Abra:

```bash
less simulation/reg_if.v
```

Uma interface SystemVerilog agrupa sinais que pertencem ao mesmo protocolo.
Aqui ela junta:

```text
rstn
addr
wdata
rdata
wr
sel
ready
```

Por que isso importa?

Porque as classes de verificacao nao vao manipular fios soltos um por um. Elas
recebem um `virtual reg_if`, isto e, uma referencia para a interface real do
testbench.

Por enquanto, guarde apenas esta frase:

```text
interface e o cabo organizado entre DUT e testbench.
virtual interface e a forma de uma classe acessar esse cabo.
```

## 4. O filelist: reg_array.f

Abra:

```bash
less simulation/reg_array.f
```

Ele lista os arquivos que o VCS precisa compilar:

```text
reg_if.v
../rtl/reg_array.sv
transaction_object.sv
Driver.sv
Monitor.sv
scoreboard.sv
env.sv
test.sv
tb.v
```

Nesta etapa, o `reg_array.f` e mais importante que o Makefile.

O Makefile so chama:

```bash
vcs -sverilog -f reg_array.f
```

O `-f reg_array.f` significa: "VCS, leia a lista de arquivos daqui".

## 5. O Makefile desta etapa

Abra:

```bash
less simulation/Makefile
```

Ele e pequeno de proposito. Os comandos sao:

```bash
make help
make comp
make sim
make test
make waves
make clean
```

Nesta primeira aula, Makefile significa apenas:

```text
um arquivo que guarda comandos repetitivos com nomes curtos
```

Exemplo:

```text
make comp
```

substitui:

```bash
vcs -sverilog -f reg_array.f -debug_access+all -kdb -l comp.log
```

Nao tente aprender Makefile inteiro agora. Aprenda so a ideia de alvo:

```text
alvo:
    comando que sera executado
```

## 6. Ordem cronologica para rodar

No servidor:

```bash
cd ~/curso
git pull --ff-only origin main
cd 01/simulation
```

Se necessario, carregue as ferramentas:

```bash
module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6
```

Veja ajuda:

```bash
make help
```

Compile:

```bash
make comp
```

O que observar:

```bash
less comp.log
```

Procure erros de compilacao. Se compilar, o VCS deve gerar o executavel:

```text
simv
```

Simule:

```bash
make sim
```

O que observar:

```bash
less sim.log
```

Procure mensagens das classes:

```text
Driver
Monitor
Scoreboard
```

Abra waveform:

```bash
make waves
```

Se o Verdi abrir, procure:

```text
tb._if.addr
tb._if.wdata
tb._if.rdata
tb._if.wr
tb._if.sel
tb._if.ready
```

## 7. O que nao precisa entender ainda

Nao precisa dominar ainda:

```text
mailbox
scoreboard
classe env
randomize
fork/join
```

Eles aparecem porque o lab ja e mais avancado que uma simulacao manual. Mas o
nosso estudo vai subir um degrau por vez.

Nesta etapa, voce so precisa entender:

```text
DUT em rtl/
testbench em simulation/
filelist dizendo a ordem dos arquivos
Makefile encurtando compilar e simular
Verdi abrindo a waveform
```

## 8. Perguntas de verificacao

Depois de rodar, responda:

```text
1. Qual arquivo contem o DUT?
2. Qual arquivo contem o top do testbench?
3. Qual arquivo lista tudo que o VCS compila?
4. Qual comando cria o simv?
5. Qual comando roda o simv?
6. Qual arquivo de log mostra erro de compilacao?
7. Qual arquivo de log mostra a execucao da simulacao?
```

Se essas sete respostas ficarem claras, o Lab 01 cumpriu o papel.

## 9. Proximo passo

O Lab 02 deve ser pequeno tambem.

Sugestao para o proximo passo:

```text
separar melhor o testbench em camadas:
transaction -> driver -> monitor -> scoreboard -> env -> test -> tb
```

Ou seja, antes de mexer em sintese, vamos entender a arquitetura de verificacao
que o proprio lab SystemVerilog ja trouxe.
