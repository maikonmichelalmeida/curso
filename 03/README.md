# 03 - Mini datapath e constraints graduais

Este lab pega dois blocos que voce ja criou no Lab 02:

- `alu.sv`: bloco combinacional;
- `regbank.sv`: bloco sequencial.

Eles foram ligados em um modulo pequeno chamado `mini_datapath.sv`.

A meta nao e criar uma CPU. A meta e criar um circuito pequeno o bastante para
entender, mas completo o bastante para estudar constraints:

```text
entradas externas -> registradores -> ALU -> registrador -> saidas externas
```

## Estrutura

```text
03/
  Makefile
  rtl/
    alu.sv
    regbank.sv
    mini_datapath.sv
  tb/
    tb_mini_datapath.sv
  simulation/
    filelist_mini_datapath.f
    Makefile
  synthesis/
    Makefile
    scripts/
      common_setup.tcl
      dc_setup.tcl
      run_dc.tcl
      constraints_level0.tcl
      constraints_level1.tcl
      constraints_level2.tcl
      constraints_level3.tcl
      constraints_level4.tcl
      constraints_level5.tcl
      constraints_level6.tcl
```

## Roteiro rapido

O Makefile procura regras no diretorio atual. Por isso estes comandos precisam
ser executados nas pastas certas. Se voce rodar `make doctor` em `~/curso`, o
Makefile de `03/synthesis` nao sera visto.

No servidor, primeiro rode simulacao RTL:

```bash
module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6
cd ~/curso/03/simulation
make doctor
make test
```

Depois rode sintese gradual:

```bash
cd ~/curso/03/synthesis
module load designcompiler/W-2024.09-SP5-4
make doctor
make syn LEVEL=0
make syn LEVEL=1
make syn LEVEL=2
make syn LEVEL=3
make syn LEVEL=4
make syn LEVEL=5
make syn LEVEL=6
```

Os principais resultados da sintese ficam aqui:

```text
03/synthesis/run/levelN/      log principal do dc_shell: dc_levelN.log
03/synthesis/reports/         report_qor, report_timing, report_area etc.
03/synthesis/unmapped/        design antes do compile_ultra mapear tudo
03/synthesis/mapped/          netlist e DDC ja mapeados para a tecnologia
```

Se `make doctor` disser que `dc_shell` nao foi encontrado, ainda falta carregar
o modulo do Design Compiler/DC NXT no servidor. Para descobrir o nome disponivel:

```bash
module avail dc
module avail design
module avail compiler
module avail synopsys
```

No seu servidor, o modulo encontrado foi:

```bash
module load designcompiler/W-2024.09-SP5-4
```

Se `make doctor` disser que a biblioteca SAED32 nao foi encontrada, prepare a
pasta `../ref` exatamente no formato usado pelo Lab Guide de DC NXT. Essa pasta
deve vir do pacote de referencia da aula e conter `DBs`, `CLIBs` e `tech`:

```text
03/ref/
  DBs/saed32lvt_ss0p75v125c.db
  CLIBs/saed32_lvt.ndm
  tech/saed32nm_1p9m.tf
  tech/saed32nm_1p9m_Cmax.tluplus
  tech/saed32nm_tf_itf_tluplus.map
```

O procedimento didatico correto e preparar a arvore `ref` do Lab 03, como a
aula de setup fisico recomenda. Se voce tiver a pasta `ref` do pacote DC NXT em
outro local, pode evitar copia de arquivos grandes criando um link simbolico:

```bash
make link-ref SAED32_SOURCE_REF=/caminho/do/pacote/07_DCNXT_2021.06/ref
```

Isso cria:

```text
~/curso/03/ref -> /caminho/do/pacote/07_DCNXT_2021.06/ref
```

Depois disso, `make doctor` e `make syn LEVEL=0` usam simplesmente `../ref`.

Nao use como roteiro um caminho achado por acaso dentro de outro projeto do
servidor. Isso pode ate funcionar tecnicamente, mas esconde o aprendizado que a
aula quer construir: `common_setup.tcl` aponta para uma arvore `ref` conhecida,
e `dc_setup.tcl` usa essa arvore para configurar bibliotecas logicas e fisicas.

Use `make find-lib` somente como plano B de diagnostico, se voce nao souber onde
o pacote da aula foi instalado. Ele nao substitui o metodo da aula:

```bash
cd ~/curso/03/synthesis
make find-lib
```

## O nucleo da sintese sem o Makefile

Antes de ver o fluxo automatizado, vale enxergar a sintese como uma sequencia
pequena de comandos TCL. Este exemplo nao substitui os scripts do lab; ele serve
para mostrar que o Makefile nao e "a sintese". O Makefile apenas automatiza
comandos como estes:

```tcl
set_app_var search_path "$search_path ../ref/DBs ../rtl"
set_app_var target_library saed32lvt_ss0p75v125c.db
set_app_var synthetic_library dw_foundation.sldb
set_app_var link_library "* $target_library $synthetic_library"

analyze -format sverilog {
  ../rtl/regbank.sv
  ../rtl/alu.sv
  ../rtl/mini_datapath.sv
}

elaborate mini_datapath -param "WIDTH=8"
set ELABORATED_TOP [get_object_name [current_design]]
puts "Design elaborado: $ELABORATED_TOP"

link
check_design

compile_ultra

report_area
report_reference

write_file -format verilog -hierarchy \
  -output mini_datapath_mapped.v
```

Linha por linha:

- `search_path`: diz onde o DC deve procurar arquivos. Aqui entram `../ref/DBs`
  para a biblioteca `.db` e `../rtl` para os fontes.
- `target_library`: escolhe a biblioteca de celulas que vai receber o
  mapeamento tecnologico. No nosso caso, `saed32lvt_ss0p75v125c.db`.
- `synthetic_library`: inclui DesignWare. Isso importa porque a ALU usa `*` e
  `/`; divisao e multiplicacao podem virar componentes DesignWare.
- `link_library`: diz onde resolver referencias. O `*` significa "tambem use
  designs ja carregados na memoria".
- `analyze`: le os arquivos SystemVerilog. Ainda nao existe hardware elaborado;
  o DC apenas analisou os modulos.
- `elaborate`: cria a hierarquia parametrizada. Com `WIDTH=8`, o top pode virar
  um design especializado como `mini_datapath_WIDTH8`.
- `current_design`: depois do `elaborate`, aponta para o design elaborado. Nao
  devemos voltar cegamente para `mini_datapath`, porque esse nome pode nao ser o
  nome interno especializado.
- `link`: conecta instancias como `u_reg_a`, `u_reg_b`, `u_alu` e
  `u_result_reg` aos modulos e bibliotecas carregadas.
- `check_design`: procura problemas estruturais.
- `compile_ultra`: otimiza e mapeia a logica para celulas da biblioteca.
- `report_area` e `report_reference`: mostram area e quais referencias/celulas
  foram usadas.
- `write_file`: grava uma netlist mapeada.

Evidencias esperadas no log:

```text
Analyzing design file '../rtl/alu.sv'
Elaborated design 'mini_datapath_WIDTH8'
INFO Lab03: design elaborado e selecionado = mini_datapath_WIDTH8
```

Erros comuns:

- `dc_shell: command not found`: faltou `module load designcompiler/...`.
- `Can't find design 'mini_datapath' (UID-109)`: tentativa de selecionar o nome
  generico depois de elaborar um design parametrizado.
- `Unable to find target library`: `REF_ROOT` ou `../ref/DBs` esta errado.
- `link` com referencias nao resolvidas: algum RTL nao foi analisado ou alguma
  biblioteca nao entrou no `link_library`.

O projeto profissionalizado distribui esse mesmo nucleo assim:

```text
common_setup.tcl
  variaveis e caminhos da tecnologia.

dc_setup.tcl
  aplica search_path, target_library, link_library e DesignWare.

run_dc.tcl
  roda analyze, elaborate, link, constraints, compile_ultra e reports.

constraints_levelN.tcl
  adiciona os requisitos do design por nivel.

Makefile
  automatiza comandos repetitivos e cria os diretorios de saida.
```

## Configuracao basica da Synopsys

Antes de constraints, existem duas configuracoes basicas:

```text
1. ferramenta no PATH
2. bibliotecas da tecnologia no search_path/target_library/link_library
```

Ferramenta no PATH:

```bash
module load designcompiler/W-2024.09-SP5-4
command -v dc_shell
```

Biblioteca logica:

```text
ref/DBs/saed32lvt_ss0p75v125c.db
```

Esse arquivo diz para o Design Compiler quais celulas logicas existem, quais sao
seus atrasos, capacitancias, potencia e restricoes eletricas. Para sintese
logica, este e o arquivo essencial.

Bibliotecas fisicas:

```text
ref/CLIBs/saed32_lvt.ndm
ref/tech/saed32nm_1p9m.tf
ref/tech/saed32nm_1p9m_Cmax.tluplus
ref/tech/saed32nm_tf_itf_tluplus.map
```

Esses arquivos sao necessarios para fluxo fisico/topographical. O Lab 03 ainda
comeca pela sintese logica, mas o `common_setup.tcl` ja explica a organizacao
para voce reconhecer o setup do curso.

No fluxo atual, com `ENABLE_PHYSICAL_SETUP=0` ou `PHYS_SETUP=0`, a diferenca e:

```text
Encontrado/verificado pelo doctor:
  .db, .ndm, .tf, .tluplus, map file

Efetivamente usado na sintese logica:
  saed32lvt_ss0p75v125c.db
  dw_foundation.sldb

Nao usado enquanto PHYS_SETUP=0:
  saed32_lvt.ndm
  saed32nm_1p9m.tf
  saed32nm_1p9m_Cmax.tluplus
  saed32nm_tf_itf_tluplus.map
```

Se o report indicar algo como `Flow: Design Compiler WLM`, isso significa
sintese logica com wire-load model. Nao e ainda sintese topographical com
placement fisico. NDM, technology file e TLUPlus ficam como proximo degrau.

Como isso conversa com o material das aulas:

```text
02_Design_Setup_for_Physical_Synthesis_parte_B.md
  slides 34-35: create_lib/open_lib, check_library, TLUPlus e map file.
  slides 44-45: separacao entre common_setup.tcl e dc_setup.tcl.

04_Constraints_Reg_to_Reg_and_IO_Timing_parte_A/B.md
  create_clock, set_clock_uncertainty, set_clock_latency,
  set_clock_transition, set_input_delay, set_output_delay e check_timing.

05_Constraints_Input_Transition_and_Output_Loading.md
  set_driving_cell, set_max_capacitance, set_load e load_of.

12_Design_Compiler_NXT_RTL_Synthesis_2021_06_Lab_Guide.md
  Lab 1: ADDITIONAL_SEARCH_PATH, TARGET_LIBRARY_FILES,
         NDM_DESIGN_LIB, NDM_REFERENCE_LIBS, TECH_FILE,
         TLUPLUS_MAX_FILE e MAP_FILE.
```

Neste Lab 03 eu estou fazendo uma etapa anterior e mais didatica: primeiro
garantimos que voce entende `search_path`, `target_library`, `link_library` e
constraints basicas usando a biblioteca `.db`. O fluxo DC NXT/topographical
completo, com `create_lib`, `.ndm`, `.tf`, TLUPlus e map file, fica preparado no
guia para ser o proximo degrau, sem misturar tudo no primeiro contato.

Nos scripts isso aparece assim:

```text
scripts/common_setup.tcl
  variaveis editaveis do projeto: ADDL_SEARCH_PATH, TARGET_LIBS,
  NDM_REFERENCE_LIBS, TECH_FILE, TLUPLUS_MAX_FILE e MAP_FILE.

scripts/dc_setup.tcl
  aplica search_path, target_library e link_library; e, quando
  ENABLE_PHYSICAL_SETUP=1, executa create_lib/open_lib, check_library,
  set_tlu_plus_files e check_tlu_plus_files.
```

Variaveis principais no nosso Makefile:

```bash
REF_ROOT=/caminho/para/ref
TARGET_DB=saed32lvt_ss0p75v125c.db
DRIVE_LIB=saed32lvt_ss0p75v125c
DRIVE_CELL=NBUFFX2_LVT
LOAD_CELL=NBUFFX16_LVT
```

Esses nomes acompanham o Lab Guide de DC NXT: uma celula buffer pequena modela
quem dirige as entradas, e uma celula buffer maior serve como referencia de
carga para `load_of`.

O material antigo `04 ces_svrtl_2019.03` usa outro layout:

```text
ref/SAED32_2012-12-25/lib/stdcell_hvt/db_nldm/saed32hvt_ss0p75v125c.db
```

Por isso o Makefile ainda aceita `REF_LIB=/caminho/SAED32_2012-12-25`, mas o
roteiro principal do Lab 03 segue o estilo DC NXT com `REF_ROOT`.

Para estudar efeito de largura:

```bash
make syn LEVEL=5 WIDTH=16
```

## Niveis de constraints

Cada nivel deve responder uma pergunta. Nao leia os niveis como uma lista de
comandos soltos.

| Nivel | Pergunta | Comandos adicionados | Mudanca esperada nos reports | O que ainda nao conclui |
| --- | --- | --- | --- | --- |
| `LEVEL=0` | O fluxo basico roda? | Nenhuma constraint real. | `analyze`, `elaborate`, `link`, `compile_ultra` e mapeamento tecnologico rodam. | `Number of Clocks = 0` e `WNS = 0.00` nao significam timing fechado. Sem clock, nao ha requisito temporal real. |
| `LEVEL=1` | O caminho `reg_a/reg_b -> u_alu -> result_reg` cabe em 10 ns? | `create_clock`, `set_false_path` no reset. | Passa a existir clock, path group e slack de setup. | O ambiente externo ainda e ideal: sem input delay, output delay, driving cell ou load. |
| `LEVEL=2` | Quanto tempo o mundo externo consome nas entradas e saidas? | `set_input_delay`, `set_output_delay`. | Timing de I/O passa a aparecer com atrasos externos modelados. | Ainda nao sabemos quem dirige as entradas nem qual carga as saidas dirigem. |
| `LEVEL=3` | O clock ainda passa com margens mais realistas? | `set_clock_uncertainty`, `set_clock_latency`, `set_clock_transition`. | O slack tende a ficar menor porque parte do periodo vira margem. | Ainda falta modelo eletrico de portas externas. |
| `LEVEL=4` | O bloco ainda passa dirigindo/recebendo cargas simples? | `set_driving_cell`, `set_max_capacitance`, `set_load`. | Area e buffers podem mudar; `report_constraint` fica mais significativo. | Ainda nao e layout fisico; e apenas um modelo eletrico simples. |
| `LEVEL=5` | Como ler uma rodada completa o bastante? | Reusa o nivel 4. | Ponto principal para ler `report_qor`, `report_timing`, `report_area`, `report_resources`. | Nao adiciona uma constraint nova; o exercicio e interpretar reports. |
| `LEVEL=6` | O que acontece se o clock apertar para 4 ns? | Repete o modelo com clock e delays mais agressivos. | Pode aparecer violacao ou aumento de area/otimizacao. | Violacao de timing nao prova erro de RTL; prova que o requisito temporal nao foi atendido. |

## Como interpretar este mini_datapath nos reports

Com `WIDTH=8`, a hierarquia parametrizada pode aparecer com nomes como:

```text
mini_datapath_WIDTH8
alu_00000008
regbank_00000008
regbank_00000010
```

`00000010` esta em hexadecimal. `0x10 = 16`. Esse `regbank_00000010`
corresponde ao `u_result_reg`, porque `result_out` tem largura `2*WIDTH`.

A contagem de registradores esperada e:

```text
u_reg_a        = 8 flip-flops
u_reg_b        = 8 flip-flops
u_result_reg   = 16 flip-flops
zero_out_reg   = 1 flip-flop
error_out_reg  = 1 flip-flop
Total          = 34 flip-flops
```

Por isso `Sequential Cell Count = 34` faz sentido para `WIDTH=8`.

DesignWare aparece por causa do RTL real da ALU:

```systemverilog
OP_MUL: out = in1 * in2;
OP_DIV: out = {{WIDTH{1'b0}}, in1} / {{WIDTH{1'b0}}, in2};
```

Blocos como `DW_div_uns_a_width8_b_width8` e
`DW_div_a_width8_b_width8_tc_mode0_rem_mode1` estao ligados ao operador de
divisao. Eles nao aparecem "magicamente"; sao a forma como o DC representa uma
operacao aritmetica mais pesada.

O warning abaixo e esperado no arquivo salvo antes do `compile_ultra`:

```text
Module alu_00000008 contains unmapped components. (VO-12)
```

O `unmapped/*.v` e uma representacao intermediaria. Ele pode conter GTECH ou
DesignWare ainda nao mapeados. A netlist tecnologicamente mapeada fica em
`mapped/*.v`.

## Como depurar por camadas

Use esta separacao para nao misturar problemas:

| Camada | Exemplo | O que significa |
| --- | --- | --- |
| Linux/shell | `dc_shell: nao encontrado` | Falta `module load` ou PATH correto. |
| Diretorio atual | `No rule to make target 'doctor'` | Voce rodou `make doctor` fora de `03/synthesis` ou `03/simulation`. |
| Makefile | `TARGET_DB nao encontrado` | `REF_ROOT` nao aponta para uma pasta `ref` com `DBs/`. |
| TCL | `UID-109 em current_design` | Nome errado apos elaboracao parametrizada. O fluxo agora usa o design selecionado pelo `elaborate`. |
| Design Compiler | `link` falhou | Modulo RTL ou biblioteca nao foi carregado/resolvido. |
| Biblioteca | `.db` ausente | A pasta `03/ref` nao veio do pacote DC NXT correto ou esta incompleta. |
| Constraints | `Number of Clocks = 0` | Falta `create_clock`; isso e esperado no `LEVEL=0`. |
| Unmapped | `VO-12` antes do compile | Representacao pre-mapeamento ainda pode conter DesignWare/GTECH. |
| Reports | `timing violation` | Requisito temporal nao atendido; nao e automaticamente erro funcional de RTL. |

## O que o aluno precisa dominar agora

Prioridade neste lab:

- `analyze`
- `elaborate`
- `link`
- `target_library`
- `link_library`
- `compile_ultra`
- diferenca entre `mapped` e `unmapped`
- `create_clock`
- `report_timing`
- `report_area`

Assuntos para depois:

- `find-lib` sofisticado;
- portabilidade para multiplos servidores;
- NDM;
- TLUPlus;
- floorplan;
- sintese fisica/topographical;
- tratamento de todos os casos de erro.

## Guia HTML

O guia detalhado fica em:

```text
C:\Users\maiko\ci_expert\curso\guia\03.html
```

Ele tem secoes recolhiveis para esconder ou abrir explicacoes longas.
