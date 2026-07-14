# Roteiro manual do dc_shell - Lab 02B

Este e o caderno de bancada da sintese. Nao copie o bloco inteiro de uma vez.
Digite uma linha, leia a resposta e anote o que mudou. O texto exato das
mensagens pode variar entre versoes do Design Compiler; por isso, quando o
roteiro fala em "linha esperada", ele indica a frase ou o padrao que deve ser
procurado no log.

## Mapa mental antes de abrir a ferramenta

```text
Bash
  abre dc_shell e grava o log

dc_shell / TCL Synopsys
  configura biblioteca
  le o RTL
  constroi a hierarquia
  resolve referencias
  salva o estado unmapped
  aplica clock
  compila e mapeia
  gera reports e netlist
```

Um comando digitado no Bash nao e automaticamente um comando do `dc_shell`.
Depois que o prompt da Synopsys aparece, voce esta dentro de um interpretador
TCL com comandos adicionais do Design Compiler.

## Fase 0 - preparar a sessao no Bash

Comandos exatos:

```bash
cd ~/curso/02B/synthesis
module load designcompiler/W-2024.09-SP5-4
mkdir -p logs reports mapped unmapped
ls -l ../../03/ref/DBs/saed32lvt_ss0p75v125c.db
dc_shell | tee logs/manual_sem_clock.log
```

Resultado esperado: o `ls` mostra a biblioteca e o prompt muda para o prompt do
Design Compiler. O arquivo `logs/manual_sem_clock.log` passa a receber uma
copia do que aparece na tela.

Pergunta: por que o caminho da biblioteca comeca com `../../03`?

Explicacao curta: voce esta em `02B/synthesis`; o primeiro `..` volta para
`02B`, o segundo volta para `curso`, e entao o caminho entra em `03/ref/DBs`.

## Fase 1 - aprender a se orientar no dc_shell

### `pwd`

Comando:

```tcl
pwd
```

1. Ambiente: roda no `dc_shell` como comando TCL; existe tambem no Bash, mas
   aqui queremos conferir o diretorio visto pela ferramenta.
2. O que recebe: nenhum argumento.
3. O que cria ou modifica: nada; apenas consulta o diretorio atual.
4. Linha esperada no log: `/home/ciexpert/maikon.almeida/curso/02B/synthesis`.
5. Erro comum: abrir o `dc_shell` em `~/curso/02B`; nesse caso, todos os caminhos
   relativos do roteiro ficam um nivel deslocados.

Resultado esperado: confirmar que o prompt esta no diretorio `synthesis`.

Pergunta: se `pwd` terminar em `/02B`, qual comando deve ser executado antes de
continuar?

Explicacao curta: caminhos relativos sempre partem do diretorio atual do
processo, nao da pasta onde o arquivo TCL esta armazenado.

### `help analyze`

Comando:

```tcl
help analyze
```

1. Ambiente: `dc_shell`.
2. O que recebe: o nome ou padrao de um comando Synopsys.
3. O que cria ou modifica: nada; lista sintaxe/opcoes resumidas.
4. Linha esperada no log: uma entrada contendo `analyze` e suas opcoes.
5. Erro comum: digitar o comando no Bash e receber `help: analyze: no help
   topics match`, pois seria a ajuda do shell Linux, nao da Synopsys.

Resultado esperado: enxergar que `analyze` aceita formato e arquivos.

Pergunta: qual opcao informa que o arquivo e SystemVerilog?

Explicacao curta: `help` e a consulta rapida para lembrar a forma de um comando.

### `man analyze`

Comando:

```tcl
man analyze
```

1. Ambiente: `dc_shell`.
2. O que recebe: o nome exato do comando ou variavel.
3. O que cria ou modifica: nada; abre a documentacao detalhada.
4. Linha esperada no log/tela: cabecalho do manual de `analyze`.
5. Erro comum: confundir o pager do manual com travamento. Use `q` para sair do
   visualizador, se a versao abrir um pager.

Resultado esperado: encontrar descricao, sintaxe e exemplos de `analyze`.

Pergunta: qual e a diferenca pratica entre `help` e `man`?

Explicacao curta: `help` serve para consulta curta; `man` explica o comando em
profundidade.

### `printvar search_path`

Comando inicial:

```tcl
printvar search_path
```

1. Ambiente: `dc_shell`, usando uma variavel de aplicacao Synopsys.
2. O que recebe: o nome da variavel que sera consultada.
3. O que cria ou modifica: nada; imprime o valor atual.
4. Linha esperada no log: `search_path = ...` com os caminhos padrao da
   instalacao.
5. Erro comum: usar `set search_path ...` e apagar os caminhos padrao; neste lab
   usaremos `set_app_var` com `concat` para acrescentar caminhos.

Resultado esperado: perceber que a ferramenta ja possui caminhos de busca.

Pergunta: por que nao devemos substituir cegamente esse valor por `../rtl`?

Explicacao curta: a instalacao pode depender dos caminhos preexistentes para
encontrar bibliotecas e arquivos internos.

## Fase 2 - configurar somente a biblioteca logica

### `set_app_var search_path ...`

Comando:

```tcl
set_app_var search_path [concat $search_path [list "../rtl" "../../03/ref/DBs"]]
```

1. Ambiente: TCL/Synopsys dentro do `dc_shell`.
2. O que recebe: o valor atual de `search_path` e uma lista com o diretorio do
   RTL e o diretorio do arquivo `.db`.
3. O que cria ou modifica: atualiza a variavel de aplicacao `search_path`.
4. Linha esperada no log: depois de `printvar search_path`, devem aparecer
   `../rtl` e `../../03/ref/DBs`.
5. Erro comum: esquecer um nivel de `..`, fazendo a biblioteca ficar invisivel.

Conferencia:

```tcl
printvar search_path
```

Resultado esperado: os caminhos antigos continuam presentes e os dois novos
foram acrescentados.

Pergunta: qual dos dois novos caminhos serve ao RTL e qual serve a tecnologia?

Explicacao curta: `search_path` nao escolhe a biblioteca alvo; ele apenas diz
onde procurar arquivos citados por outros comandos.

### `set_app_var target_library ...`

Comando:

```tcl
set_app_var target_library [list "saed32lvt_ss0p75v125c.db"]
```

1. Ambiente: TCL/Synopsys no `dc_shell`.
2. O que recebe: o nome do arquivo compilado da biblioteca logica SAED32 LVT.
3. O que cria ou modifica: define quais celulas podem ser escolhidas durante o
   mapeamento tecnologico.
4. Linha esperada no log: `target_library = saed32lvt_ss0p75v125c.db` depois de
   executar `printvar target_library`.
5. Erro comum: passar um caminho incorreto ou usar `.v`, `.lib` ou `.ndm` no
   lugar do `.db` esperado por este fluxo logico.

Conferencia:

```tcl
printvar target_library
```

Resultado esperado: apenas a biblioteca solicitada aparece como alvo.

Pergunta: por que `target_library` e mais do que um diretorio de busca?

Explicacao curta: ela define o vocabulario de celulas permitido para o circuito
mapeado.

### `set_app_var link_library ...`

Comando:

```tcl
set_app_var link_library [concat [list "*"] $target_library]
```

1. Ambiente: TCL/Synopsys no `dc_shell`.
2. O que recebe: `*`, que inclui designs ja carregados em memoria, e o valor da
   `target_library`.
3. O que cria ou modifica: define onde o comando `link` resolve referencias.
4. Linha esperada no log: `link_library = * saed32lvt_ss0p75v125c.db` depois de
   `printvar link_library`.
5. Erro comum: omitir `*`; referencias a designs ja analisados podem deixar de
   ser consideradas durante a resolucao.

Conferencia:

```tcl
printvar link_library
```

Resultado esperado: o asterisco aparece antes da biblioteca SAED32.

Pergunta: `link_library` e `target_library` precisam ser identicas?

Explicacao curta: nao em geral. A target e usada para mapear; a link pode conter
referencias adicionais. Neste lab minimo, usamos apenas `*` e a target.

## Fase 3 - do texto RTL a uma hierarquia concreta

### `analyze`

Comando:

```tcl
analyze -format sverilog [list "../rtl/synth_intro.sv"]
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: o formato SystemVerilog e o arquivo fonte.
3. O que cria ou modifica: analisa sintaxe/semantica e cria uma representacao
   intermediaria do modulo; ainda nao cria a instancia concreta do top.
4. Linha esperada no log: procure `Analyzing` ou `Running PRESTO HDLC` e uma
   conclusao sem `Error`.
5. Erro comum: passar o testbench junto. `$fsdbDumpvars`, atrasos e estimulos nao
   pertencem ao hardware sintetizado.

Resultado esperado: o comando retorna sucesso e identifica `synth_intro`.

Pergunta: neste ponto ja existe uma netlist de celulas SAED32?

Explicacao curta: nao. Existe apenas o design analisado, ainda sem hierarquia
elaborada e sem mapeamento tecnologico.

### `elaborate`

Comando:

```tcl
elaborate synth_intro
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: o nome do modulo que deve virar o top concreto.
3. O que cria ou modifica: constroi a hierarquia, resolve larguras, geracoes e
   parametros e infere operadores/registradores genericos.
4. Linha esperada no log: procure `Elaborating design 'synth_intro'` ou
   `Elaborated ... design`.
5. Erro comum: usar o nome do testbench (`tb_synth_intro`) como top de sintese.

Resultado esperado: `synth_intro` passa a ser um design carregado.

Pergunta: qual e a diferenca entre o modulo analisado e o design elaborado?

Explicacao curta: o modulo analisado e uma definicao; a elaboracao constroi a
versao concreta que os proximos comandos vao manipular.

### `current_design`

Comando:

```tcl
current_design synth_intro
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: o design que deve ficar selecionado.
3. O que cria ou modifica: muda o contexto dos comandos seguintes; nao cria
   outra copia do circuito.
4. Linha esperada no log: o nome `synth_intro` e/ou confirmacao de que ele e o
   current design.
5. Erro comum: ter varios designs carregados e aplicar constraints ao design
   errado por nao conferir o contexto.

Conferencia:

```tcl
current_design
```

Resultado esperado: a consulta devolve `synth_intro`.

Pergunta: por que um comando de clock depende do `current_design` correto?

Explicacao curta: `[get_ports clk]` busca a porta dentro do design atualmente
selecionado.

### `link`

Comando:

```tcl
link
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: implicitamente o `current_design` e a `link_library`.
3. O que cria ou modifica: associa referencias a definicoes carregadas e a
   elementos disponiveis nas bibliotecas.
4. Linha esperada no log: procure `Linking design 'synth_intro'` e ausencia de
   `unresolved reference`.
5. Erro comum: biblioteca fora do `search_path`, nome errado no `link_library`
   ou modulo instanciado que nao foi analisado.

Resultado esperado: nenhuma referencia nao resolvida.

Pergunta: por que chamamos `link` explicitamente mesmo que `elaborate` possa
realizar parte dessa resolucao?

Explicacao curta: porque queremos tornar a etapa visivel e conferir seu
resultado antes de compilar.

### `check_design`

Comando:

```tcl
check_design
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: implicitamente o design atual.
3. O que cria ou modifica: nao altera o circuito; verifica problemas
   estruturais, conexoes e consistencia.
4. Linha esperada no log: resumo sem erros graves e retorno verdadeiro (`1`) em
   uma execucao limpa.
5. Erro comum: interpretar todo warning como fatal ou, no extremo oposto,
   ignorar avisos sobre pinos sem conexao e referencias nao resolvidas.

Resultado esperado: o design esta estruturalmente apto para continuar.

Pergunta: `check_design` prova que o comportamento funcional esta correto?

Explicacao curta: nao. Essa confianca vem da simulacao; `check_design` verifica
consistencia estrutural dentro da ferramenta.

## Fase 4 - salvar o estado unmapped

### `write_file` em DDC antes do compile

Comando:

```tcl
write_file -format ddc -hierarchy -output "unmapped/synth_intro_sem_clock.ddc"
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: formato DDC, opcao para incluir hierarquia e caminho de saida.
3. O que cria ou modifica: cria uma fotografia do banco de dados antes do
   `compile_ultra`; nao modifica o design em memoria.
4. Linha esperada no log: mensagem de escrita do arquivo DDC e o caminho
   `unmapped/synth_intro_sem_clock.ddc`.
5. Erro comum: a pasta `unmapped` nao existir ou confundir DDC com Verilog.

Resultado esperado: o arquivo `.ddc` aparece em `unmapped/`.

Pergunta: por que esse arquivo e chamado unmapped se a target library ja foi
configurada?

Explicacao curta: configurar a target apenas oferece celulas; o mapeamento para
elas acontece no `compile_ultra`.

## Fase 5 - primeira compilacao, ainda sem clock

### `compile_ultra`

Comando:

```tcl
compile_ultra
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: implicitamente o design atual, bibliotecas e constraints
   existentes; nesta primeira execucao nao existe clock.
3. O que cria ou modifica: otimiza a logica generica e a mapeia para celulas da
   `target_library`.
4. Linha esperada no log: procure fases contendo `Mapping Optimization` e uma
   conclusao de compile sem erro fatal.
5. Erro comum: concluir que um compile sem clock prova fechamento de timing. A
   ferramenta mapeou o circuito, mas nao recebeu periodo a cumprir.

Resultado esperado: a representacao interna passa de generica/unmapped para
celulas SAED32 mapeadas.

Pergunta: o que o Design Compiler ainda nao sabe sobre desempenho?

Explicacao curta: ele nao sabe qual periodo de clock representa a meta do
projeto.

### `report_area`

Comando:

```tcl
report_area
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: implicitamente o design mapeado atual.
3. O que cria ou modifica: nao modifica o design; calcula e imprime estatisticas
   de area com base na biblioteca.
4. Linha esperada no log: cabecalho `Area` e uma linha `Total cell area`.
5. Erro comum: tratar area como quantidade de transistores ou dimensao final de
   layout. Aqui e uma estimativa baseada em celulas, antes da sintese fisica.

Para guardar o report:

```tcl
redirect -tee -file "reports/area_sem_clock.rpt" { report_area }
```

Resultado esperado: o report aparece na tela e em arquivo.

Pergunta: por que a area pode mudar depois que adicionamos um clock?

Explicacao curta: uma meta temporal pode levar a ferramenta a escolher celulas
maiores/mais rapidas ou reorganizar a logica.

### `report_reference`

Comando:

```tcl
report_reference
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: implicitamente o design atual.
3. O que cria ou modifica: nao modifica nada; lista tipos de celula/referencia e
   quantas instancias foram usadas.
4. Linha esperada no log: tabela com `Reference` e nomes de celulas SAED32. As
   linhas sequenciais devem representar, somadas, 25 bits registrados.
5. Erro comum: esperar que o total de todas as referencias seja 25. Somadores,
   muxes de enable e logica de reset acrescentam celulas combinacionais.

Para guardar o report:

```tcl
redirect -tee -file "reports/reference_sem_clock.rpt" { report_reference }
```

Resultado esperado: nomes genericos como GTECH deixam de dominar; aparecem
referencias da biblioteca tecnologica.

Pergunta: quais linhas do report correspondem aos flip-flops?

Explicacao curta: procure referencias sequenciais/DFF e some suas quantidades;
os nomes exatos dependem da nomenclatura SAED32 escolhida pelo mapeador.

### `write_file` mapeado

Comandos:

```tcl
write_file -format verilog -hierarchy -output "mapped/synth_intro_sem_clock.v"
write_file -format ddc -hierarchy -output "mapped/synth_intro_sem_clock.ddc"
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: formato de saida, hierarquia e nome do arquivo.
3. O que cria ou modifica: grava a netlist estrutural Verilog e o banco interno
   DDC; nao altera o design em memoria.
4. Linha esperada no log: mensagens de escrita contendo os dois caminhos em
   `mapped/`.
5. Erro comum: abrir o Verilog mapped e esperar encontrar `always_ff`; agora ele
   deve conter instancias de celulas.

Resultado esperado: existem uma netlist `.v` e um design `.ddc` mapeados.

Pergunta: qual dos dois formatos e mais apropriado para reabrir o estado completo
no Design Compiler?

Explicacao curta: o DDC. O Verilog e melhor para intercambiar a estrutura com
outras ferramentas.

Encerre a primeira sessao:

```tcl
exit
```

## Fase 6 - segunda execucao, agora com clock

No Bash, abra uma sessao nova:

```bash
cd ~/curso/02B/synthesis
dc_shell | tee logs/manual_com_clock.log
```

Repita setup, analyze, elaborate, current_design, link, check_design e a escrita
unmapped. Em seguida, digite os comandos abaixo.

### `create_clock -period 10`

Comando:

```tcl
create_clock -period 10 [get_ports clk]
```

1. Ambiente: comando Synopsys/SDC no `dc_shell`.
2. O que recebe: periodo 10 e a colecao contendo a porta `clk` do design atual.
3. O que cria ou modifica: cria um objeto clock e associa a ele uma exigencia
   temporal; nao cria um sinal oscilando na simulacao.
4. Linha esperada no log: o proprio comando pode ser silencioso; a confirmacao
   obrigatoria vem no `report_clock`, com clock `clk` e periodo `10.00`.
5. Erro comum: `[get_ports clk]` devolver colecao vazia porque o current design
   esta errado ou a porta tem outro nome.

Resultado esperado: o design passa a ter uma meta para caminhos sequenciais.

Pergunta: 10 ns correspondem a qual frequencia ideal? Resposta: 100 MHz.

Explicacao curta: frequencia e o inverso do periodo; 1 / 10 ns = 100 MHz.

### `report_clock`

Comando:

```tcl
report_clock
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: nenhuma opcao nesta versao minima.
3. O que cria ou modifica: nada; lista os clocks conhecidos.
4. Linha esperada no log: uma linha para `clk` com periodo `10.00` e waveform
   padrao equivalente a bordas em 0 e 5 ns.
5. Erro comum: report vazio, indicando que `create_clock` nao encontrou a porta
   ou nao foi aplicado ao design certo.

Resultado esperado: exatamente um clock real associado a porta `clk`.

Pergunta: o report mostra input/output delays? Nao, porque ainda nao os criamos.

Explicacao curta: `report_clock` confirma o objeto clock, nao completa o modelo
do ambiente externo.

### `check_timing`

Comando:

```tcl
check_timing
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: implicitamente o design atual e suas constraints.
3. O que cria ou modifica: nao altera o circuito; procura problemas que impedem
   uma analise temporal confiavel.
4. Linha esperada no log: resumo de timing checks. Avisos sobre I/O sem delay
   podem aparecer e sao esperados neste escopo deliberadamente incompleto.
5. Erro comum: tentar "corrigir" todos os avisos adicionando constraints que
   ainda nao foram estudadas. Aqui devemos registrar os limites do modelo.

Resultado esperado: o clock e reconhecido; as limitacoes de I/O ficam
documentadas.

Pergunta: por que um warning de input sem delay nao invalida o objetivo desta
primeira experiencia?

Explicacao curta: estamos isolando o caminho interno reg-to-reg e deixando o
mundo externo para o Lab 03.

Compile novamente:

```tcl
compile_ultra
```

Agora o mesmo comando recebe implicitamente uma constraint a mais: o clock de
10 ns. Essa e a unica diferenca intencional entre as duas execucoes.

### `report_timing`

Comando:

```tcl
report_timing
```

1. Ambiente: comando Synopsys no `dc_shell`.
2. O que recebe: implicitamente o design compilado, a biblioteca e o clock.
3. O que cria ou modifica: nada; calcula e imprime o caminho temporal mais
   critico segundo as opcoes padrao.
4. Linha esperada no log: `Startpoint`, `Endpoint`, `data arrival time`,
   `data required time` e `slack (MET)` ou `slack (VIOLATED)`.
5. Erro comum: olhar somente a palavra MET e ignorar quais registradores formam
   o caminho, quanto tempo sobrou e o que ainda nao foi modelado.

Resultado esperado: um caminho interno entre registradores, normalmente saindo
de `a_q`/`b_q` e chegando a `result`.

Pergunta: se o slack for 8 ns, isso prova que uma placa real tera exatamente 8
ns de margem?

Explicacao curta: nao. Ainda faltam incerteza, parasitas, variacoes e ambiente de
I/O; o valor pertence ao modelo logico atual.

Salve a segunda execucao:

```tcl
report_area
report_reference
write_file -format verilog -hierarchy -output "mapped/synth_intro_com_clock.v"
write_file -format ddc -hierarchy -output "mapped/synth_intro_com_clock.ddc"
exit
```

## Fase 7 - reunir o que ja foi entendido em um script

Somente agora rode no Bash:

```bash
cd ~/curso/02B/synthesis
mkdir -p logs
dc_shell -f run_minimal.tcl | tee logs/run_minimal.log
```

### `dc_shell -f run_minimal.tcl`

1. Ambiente: Bash inicia o `dc_shell`; o conteudo do arquivo roda como
   TCL/Synopsys.
2. O que recebe: um unico arquivo TCL, em ordem linear e sem includes.
3. O que cria ou modifica: repete a execucao com clock, cria reports e grava
   saidas; nao muda o RTL fonte.
4. Linha esperada no log: marcos `LAB02B: inicio`, `biblioteca logica
   configurada`, `compile_ultra e reports concluidos` e `fim`.
5. Erro comum: rodar o script antes das etapas manuais e continuar sem entender
   em qual comando surgiu um erro.

Resultado esperado: a mesma sequencia manual se torna reproduzivel.

Pergunta: o que um Makefile acrescentaria agora?

Explicacao curta: um alvo poderia criar `logs/` e executar exatamente
`dc_shell -f run_minimal.tcl`. Ele nao mudaria o significado de nenhum comando
de sintese. Essa camada fica para o Lab 03.

## Comparacao que deve ser feita

Compare:

```text
reports/area_sem_clock.rpt
reports/reference_sem_clock.rpt
logs/manual_sem_clock.log

com

logs/manual_com_clock.log
reports/area_minimal.rpt
reports/reference_minimal.rpt
reports/timing_minimal.rpt
```

Perguntas finais:

1. As referencias de flip-flop somam 25 bits nas duas execucoes?
2. O numero/tipo de celulas combinacionais mudou com o clock?
3. Qual foi o startpoint do pior caminho?
4. Qual foi o endpoint?
5. Qual foi o slack?
6. Por que esse slack ainda nao representa o sistema completo?

## O que ainda nao estamos estudando

Nao adicione a este roteiro:

- input delay ou output delay;
- clock uncertainty ou clock latency;
- driving cell ou load;
- max capacitance, max transition ou max fanout;
- NDM, technology file, TLUPlus ou map file;
- topographical mode, placement, routing ou SPG;
- scan, retiming ou DesignWare.

Esses elementos nao sao irrelevantes. Eles foram retirados para que voce
consiga explicar com seguranca o nucleo da sintese antes de voltar ao Lab 03.

## Do Lab 02.5 para o Lab 03

O Lab 03 nao troca o fluxo. Ele o organiza e amplia:

```text
Lab 02B                         Lab 03
----------------------------   ------------------------------------
comandos manuais               Makefile chama o dc_shell
um run_minimal.tcl             common_setup + dc_setup + run_dc
uma biblioteca .db             setup logico e preparacao fisica
somente create_clock           niveis graduais de constraints
somador simples                ALU e DesignWare
reports essenciais             reports de QoR, constraints e recursos
```

Quando voce chegar ao Lab 03, cada camada nova devera responder a uma pergunta
que ja e compreensivel aqui. Se uma camada apenas esconder o comando, volte a
este roteiro e execute a linha correspondente manualmente.
