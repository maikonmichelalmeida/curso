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

No servidor, primeiro rode simulacao RTL:

```bash
cd ~/curso
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

Se `make doctor` disser que a biblioteca SAED32 nao foi encontrada, informe o
caminho da biblioteca ao rodar a sintese. O formato preferido agora e
`REF_ROOT`, isto e, o caminho para a pasta `ref` que contem `DBs`, `CLIBs` e
`tech`:

```bash
make find-lib
make link-ref SAED32_SOURCE_REF=/caminho/terminado/em/ref
make doctor
make syn LEVEL=0
```

O Makefile nao usa esse caminho automaticamente. O procedimento didatico correto
e preparar a arvore `ref` do Lab 03, como a aula de setup fisico recomenda.
Como nao queremos duplicar arquivos grandes, podemos usar um link simbolico para
a pasta `ref` que foi fornecida/preparada para o laboratorio:

```bash
make link-ref SAED32_SOURCE_REF=/caminho/terminado/em/ref
```

Isso cria:

```text
~/curso/03/ref -> /caminho/terminado/em/ref
```

Depois disso, `make doctor` e `make syn LEVEL=0` usam simplesmente `../ref`.

Se `make find-lib` nao existir no servidor, o servidor ainda esta com uma versao
antiga deste lab. Rode:

```bash
cd ~/curso
git pull --ff-only origin main
cd ~/curso/03/synthesis
make find-lib
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

## Niveis

- `LEVEL=0`: sem constraints reais.
- `LEVEL=1`: `create_clock`.
- `LEVEL=2`: `set_input_delay` e `set_output_delay`.
- `LEVEL=3`: `set_clock_uncertainty`, `set_clock_latency`, `set_clock_transition`.
- `LEVEL=4`: `set_driving_cell`, `set_max_capacitance`, `set_load`.
- `LEVEL=5`: ponto de leitura dos reports.
- `LEVEL=6`: clock apertado para gerar pressao de timing.

## Guia HTML

O guia detalhado fica em:

```text
C:\Users\maiko\ci_expert\curso\guia\03.html
```

Ele tem secoes recolhiveis para esconder ou abrir explicacoes longas.
