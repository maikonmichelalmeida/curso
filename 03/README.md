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

Se `make doctor` disser que `REF_LIB` nao foi encontrado, informe o caminho da
biblioteca SAED32 ao rodar a sintese:

```bash
find /home/ciexpert -name "saed32hvt_ss0p75v125c.db" 2>/dev/null
make syn LEVEL=0 REF_LIB=/caminho/para/SAED32_2012-12-25
```

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
