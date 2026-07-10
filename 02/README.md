# 02 - Seu projeto com testes por modulo

Este lab pega o seu projeto RTL e organiza o primeiro nivel de automacao:

- testar cada modulo sozinho;
- testar o `top` como integracao simples;
- usar filelists;
- usar um Makefile pequeno;
- guardar os arquivos gerados em `simulation/run/<teste>/`;
- ainda sem constraints, sintese, Tcl ou Design Compiler.

A ideia e aprender uma rotina que aparece nos labs e tambem no ambiente do
professor, mas sem pular etapas:

```text
escolher um teste -> compilar -> simular -> olhar log -> abrir waveform
```

Neste momento, a ferramenta principal e o VCS. O Verdi entra apenas para abrir
as ondas geradas pela simulacao.

Estrutura:

```text
02/
  rtl/
    mux.sv
    alu.sv
    regbank.sv
    memory.sv
    control.sv
    top.sv
  tb/
    tb_mux.sv
    tb_alu.sv
    tb_regbank.sv
    tb_memory.sv
    tb_top.sv
  simulation/
    filelist_mux.f
    filelist_alu.f
    filelist_regbank.f
    filelist_memory.f
    filelist_top.f
    Makefile
    run/
      mux/
      alu/
      regbank/
      memory/
      top/
```

No servidor:

```bash
cd ~/curso/02/simulation
make help
make list
make show TEST=mux
make doctor TEST=mux
make test TEST=mux
make test TEST=alu
make test TEST=regbank
make test TEST=memory
make test TEST=top
make all
```

## O que cada comando faz

```bash
make show TEST=alu
```

Mostra a configuracao escolhida: qual filelist sera usado, qual e o top do
testbench e onde ficarao os arquivos gerados.

```bash
make comp TEST=alu
```

Chama o VCS usando `filelist_alu.f` e gera o simulador em:

```text
simulation/run/alu/simv
```

```bash
make sim TEST=alu
```

Entra em `simulation/run/alu` e executa `./simv`. O log da simulacao fica em:

```text
simulation/run/alu/sim.log
```

```bash
make test TEST=alu
```

Faz a sequencia completa:

```text
clean -> comp -> sim
```

Para abrir onda:

```bash
make waves TEST=alu
```

O arquivo de onda fica em:

```text
simulation/run/alu/alu.fsdb
```

## Por que separar por modulo?

Se o teste geral do `top` falha, pode ser dificil descobrir onde esta o erro.
Por isso, primeiro testamos os blocos menores:

```text
mux -> alu -> regbank -> memory -> top
```

Essa ordem ajuda a construir confianca. Quando o `top` falhar, voce ja sabe que
os blocos basicos passaram isoladamente.

O guia HTML local fica em:

```text
C:\Users\maiko\ci_expert\curso\guia\02.html
```

Essa pasta `guia` esta no `.gitignore`.
