# 01 - SystemVerilog lab, primeiro contato

Este primeiro passo usa o lab de SystemVerilog do material Synopsys.

Por enquanto o objetivo e pequeno:

1. entender a pasta `rtl`;
2. entender a pasta `simulation`;
3. entender o `reg_array.f`;
4. usar um Makefile simples para compilar e simular com VCS;
5. abrir a waveform no Verdi.

Ainda nao entramos em:

- Design Compiler;
- DC_NXT;
- constraints SDC;
- Tcl de sintese;
- ambiente completo do professor.

Comece por:

```bash
cd ~/curso/01/simulation
make help
make comp
make sim
make waves
```

Leia o roteiro em:

```bash
less ../docs/guia_lab.md
```
