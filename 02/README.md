# 02 - Seu projeto com testes por modulo

Este lab pega o seu projeto RTL e organiza o primeiro nivel de automacao:

- testar cada modulo sozinho;
- testar o `top` como integracao simples;
- usar filelists;
- usar um Makefile pequeno;
- ainda sem constraints, sintese, Tcl ou Design Compiler.

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
```

No servidor:

```bash
cd ~/curso/02/simulation
make help
make test TEST=mux
make test TEST=alu
make test TEST=regbank
make test TEST=memory
make test TEST=top
make all
```

Para abrir onda:

```bash
make waves TEST=alu
```

O guia HTML local fica em:

```text
C:\Users\maiko\ci_expert\curso\guia\02.html
```

Essa pasta `guia` esta no `.gitignore`.
