# Lab 02B - introducao manual a sintese logica

Este laboratorio e a ponte entre o Lab 02, onde voce simulou RTL com VCS, e o
Lab 03, que ja usa uma estrutura maior de automacao e constraints.

A regra pedagogica e:

```text
digitar os comandos no dc_shell
        -> entender o estado criado por cada comando
        -> repetir com um clock minimo
        -> somente entao executar um unico script TCL
```

Nao existe Makefile de sintese neste lab. O Makefile nao sintetiza hardware por
si mesmo; ele apenas poderia chamar o `dc_shell` e o TCL mais tarde. Aqui, os
comandos ficam expostos para que a ferramenta deixe de parecer uma caixa-preta.

## O circuito

```text
a[7:0] -> a_q[7:0] --\
                         +-> soma[8:0] -> result[8:0]
b[7:0] -> b_q[7:0] --/
```

O armazenamento esperado e:

```text
a_q       8 flip-flops
b_q       8 flip-flops
result    9 flip-flops
total    25 flip-flops
```

O somador e combinacional. A sintese deve substitui-lo por portas/celulas da
biblioteca SAED32, enquanto os 25 bits registrados devem aparecer como celulas
sequenciais. O `report_reference` tambem mostrara celulas combinacionais, por
isso o total geral de instancias sera maior que 25. Some apenas as linhas de
flip-flops para conferir os 25 bits de estado.

## Estrutura entregue

```text
02B/
  README.md
  rtl/
    synth_intro.sv
  tb/
    tb_synth_intro.sv
  simulation/
    filelist.f
  synthesis/
    roteiro_manual_dc_shell.md
    run_minimal.tcl
```

Arquivos gerados durante a execucao, como `run/`, `logs/`, `reports/`,
`mapped/` e `unmapped/`, nao fazem parte do Git. Eles sao resultados que podem
ser recriados.

## Antes de comecar no servidor

Atualize o repositorio e carregue as ferramentas:

```bash
cd ~/curso
git pull --ff-only origin main
module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6
module load designcompiler/W-2024.09-SP5-4
```

O Lab 02B usa exatamente a biblioteca logica solicitada:

```text
saed32lvt_ss0p75v125c.db
```

Para manter compatibilidade com o Lab 03 sem copiar uma biblioteca grande, o
caminho adotado e:

```text
~/curso/03/ref/DBs/saed32lvt_ss0p75v125c.db
```

Confira manualmente:

```bash
cd ~/curso/02B/synthesis
ls -l ../../03/ref/DBs/saed32lvt_ss0p75v125c.db
```

Se o arquivo nao aparecer, pare aqui. Primeiro prepare `~/curso/03/ref` como ja
previsto pelo Lab 03. Este laboratorio nao tenta localizar bibliotecas em
outros lugares e nao altera automaticamente o ambiente.

## Fase 1 - simular o RTL

O objetivo e separar duas perguntas:

```text
VCS: o comportamento do RTL esta correto?
DC : esse RTL pode ser transformado em celulas da tecnologia?
```

Compile e simule:

```bash
cd ~/curso/02B/simulation
mkdir -p run

vcs -sverilog -timescale=1ns/1ps \
  -debug_access+all -kdb \
  -f filelist.f \
  -top tb_synth_intro \
  -o run/simv \
  -Mdir=run/csrc \
  -l run/comp.log

cd run
./simv -l sim.log
```

Resultado esperado no final de `sim.log`:

```text
LAB02B PASS: pipeline, soma, reset e enable funcionaram.
```

Para abrir as ondas:

```bash
verdi -dbdir simv.daidir -ssf synth_intro.fsdb &
```

Observe a latencia: em uma borda, `a_q` e `b_q` capturam as entradas; somente
na borda seguinte `result` recebe a soma desse par. Isso acontece porque as
atribuicoes nao bloqueantes usam os valores anteriores dos registradores na
mesma borda.

Pergunta: por que `result` ainda vale zero na primeira borda com `enable=1`,
mesmo quando `a=10` e `b=7`?

## Fase 2 - primeira sintese manual, sem clock

Leia o roteiro completo antes de executar:

```text
02B/synthesis/roteiro_manual_dc_shell.md
```

Prepare as pastas e abra o Design Compiler registrando a sessao:

```bash
cd ~/curso/02B/synthesis
mkdir -p logs reports mapped unmapped
dc_shell | tee logs/manual_sem_clock.log
```

Agora o prompt e do `dc_shell`. Digite, uma linha por vez:

```tcl
pwd
help analyze
man analyze
printvar search_path

set_app_var search_path [concat $search_path [list "../rtl" "../../03/ref/DBs"]]
set_app_var target_library [list "saed32lvt_ss0p75v125c.db"]
set_app_var link_library [concat [list "*"] $target_library]

printvar search_path
printvar target_library
printvar link_library

analyze -format sverilog [list "../rtl/synth_intro.sv"]
elaborate synth_intro
current_design synth_intro
link
check_design

write_file -format ddc -hierarchy -output "unmapped/synth_intro_sem_clock.ddc"

compile_ultra

redirect -tee -file "reports/area_sem_clock.rpt" { report_area }
redirect -tee -file "reports/reference_sem_clock.rpt" { report_reference }

write_file -format verilog -hierarchy -output "mapped/synth_intro_sem_clock.v"
write_file -format ddc -hierarchy -output "mapped/synth_intro_sem_clock.ddc"

exit
```

Esta execucao prova que o RTL pode ser analisado, elaborado, ligado e mapeado.
Ela ainda nao prova que o circuito atende a uma frequencia. Sem `create_clock`,
o Design Compiler nao recebeu uma meta de tempo para o caminho entre os
registradores.

Pergunta: se o `compile_ultra` termina sem clock, isso significa que o circuito
consegue operar a 100 MHz? A resposta e nao: ainda nao foi feita essa pergunta
a ferramenta.

## Fase 3 - repetir manualmente com um clock de 10 ns

Abra uma sessao nova. A sessao nova e importante porque evita reutilizar, sem
perceber, o design ja compilado na fase anterior:

```bash
cd ~/curso/02B/synthesis
dc_shell | tee logs/manual_com_clock.log
```

Digite novamente o setup e a leitura. A repeticao e intencional:

```tcl
set_app_var search_path [concat $search_path [list "../rtl" "../../03/ref/DBs"]]
set_app_var target_library [list "saed32lvt_ss0p75v125c.db"]
set_app_var link_library [concat [list "*"] $target_library]

analyze -format sverilog [list "../rtl/synth_intro.sv"]
elaborate synth_intro
current_design synth_intro
link
check_design

write_file -format ddc -hierarchy -output "unmapped/synth_intro_com_clock.ddc"
```

Agora acrescente a unica constraint deste laboratorio:

```tcl
create_clock -period 10 [get_ports clk]
report_clock
check_timing
compile_ultra
report_timing
report_area
report_reference

write_file -format verilog -hierarchy -output "mapped/synth_intro_com_clock.v"
write_file -format ddc -hierarchy -output "mapped/synth_intro_com_clock.ddc"
exit
```

`create_clock -period 10` declara que uma borda ativa ocorre a cada 10 ns. A
ferramenta passa a avaliar se o caminho `a_q/b_q -> somador -> result` cabe
dentro desse orcamento, descontando os requisitos internos das celulas.

No `report_timing`, procure:

- startpoint: um flip-flop pertencente a `a_q` ou `b_q`;
- endpoint: um flip-flop pertencente a `result`;
- data arrival time: quando o dado chega;
- data required time: quando ele precisava chegar;
- slack: margem entre o requerido e o realizado.

Para este circuito pequeno e periodo de 10 ns, o esperado e `slack (MET)`. Se a
versao da biblioteca ou a ferramenta produzir outro resultado, nao esconda o
report: a meta do lab e aprender a le-lo.

Pergunta: o que mudou no RTL entre a execucao sem clock e a execucao com clock?
Nada. O que mudou foi a exigencia usada pela ferramenta para otimizar e julgar
o mesmo RTL.

## Fase 4 - primeiro e unico script TCL

Somente depois das fases manuais, execute:

```bash
cd ~/curso/02B/synthesis
mkdir -p logs
dc_shell -f run_minimal.tcl | tee logs/run_minimal.log
```

O script faz a mesma sequencia da segunda execucao:

```text
configura bibliotecas
  -> analyze
  -> elaborate
  -> current_design
  -> link
  -> check_design
  -> salva DDC unmapped
  -> create_clock -period 10
  -> report_clock e check_timing
  -> compile_ultra
  -> reports
  -> grava Verilog e DDC mapped
```

Procure no log os marcos iniciados por `LAB02B:`. Eles foram colocados para
mostrar onde cada grupo de comandos terminou, nao para esconder os comandos.

## A transformacao que deve ficar clara

```text
RTL SystemVerilog
  -> analyze
design analisado
  -> elaborate
hierarquia concreta synth_intro
  -> link
referencias resolvidas
  -> compile_ultra
celulas logicas e sequenciais SAED32
  -> write_file -format verilog
netlist mapeada
```

O arquivo DDC nao substitui a netlist. Ele preserva o banco de dados interno do
Design Compiler. O Verilog mapped e a representacao estrutural que deixa
visiveis as instancias das celulas da tecnologia.

## O que ainda nao estamos estudando

Este laboratorio modela somente o clock interno. Ele ainda nao descreve:

- o mundo externo que envia `a`, `b`, `enable` e `rst`;
- quanto do periodo ja foi gasto antes de um input chegar;
- quanto tempo um receptor externo precisa depois de `result` sair;
- `input delay` e `output delay`;
- `clock uncertainty`, jitter ou margem de seguranca;
- latencia da rede de clock;
- forca da celula que dirige cada entrada;
- carga capacitiva nas saidas;
- limites de transicao, fanout ou capacitancia;
- placement, routing, parasitas ou sintese fisica.

Por isso, um `slack (MET)` aqui significa apenas: o caminho interno analisado
cabe no periodo declarado sob um ambiente externo ainda idealizado.

## Do Lab 02.5 para o Lab 03

O nome da pasta e `02B`, mas pedagogicamente ela ocupa a posicao `02.5`: uma
ponte entre simulacao organizada e o fluxo maior de sintese.

O Lab 03 acrescenta:

- separacao entre `common_setup.tcl`, `dc_setup.tcl` e `run_dc.tcl`;
- Makefiles para chamar ferramentas e selecionar niveis;
- constraints graduais alem do clock;
- DesignWare para operacoes mais complexas;
- reports mais completos e organizados;
- preparacao opcional para bibliotecas e setup fisico.

Nada disso muda o nucleo aprendido aqui. O Lab 03 apenas organiza e amplia a
mesma sequencia `analyze -> elaborate -> link -> constraints -> compile ->
reports -> write_file`.

## Checklist de conclusao

- [ ] A simulacao terminou com `LAB02B PASS`.
- [ ] Eu vi `a_q`, `b_q` e `result` mudando em ciclos diferentes.
- [ ] Eu executei a primeira sintese sem clock, digitando cada comando.
- [ ] Eu salvei um DDC antes do `compile_ultra`.
- [ ] Eu encontrei celulas SAED32 no `report_reference`.
- [ ] Eu conferi que as celulas sequenciais representam 25 bits de estado.
- [ ] Eu reabri o DC e repeti o fluxo com `create_clock -period 10`.
- [ ] Eu li startpoint, endpoint e slack no `report_timing`.
- [ ] Somente depois executei `run_minimal.tcl`.
- [ ] Eu consigo explicar que um futuro Makefile apenas chamara esse script.

O guia local, com explicacoes mais longas e fichas de cada comando, esta em:

```text
C:\Users\maiko\ci_expert\curso\guia\02B.html
```
