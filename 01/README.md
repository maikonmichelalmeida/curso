# Lab 01 - Esqueleto minimo do ambiente

Este primeiro lab nao tenta ensinar muitos erros de RTL de uma vez. O foco e
entender a estrutura que aparece nos labs Synopsys e no ambiente do professor:

```text
01/
  rtl/
  verif/
  constraints/
  tools/
    vcs/
      scripts/
      run/
    dc_nxt/
      scripts/
      run/
      outputs/
      rpt/
```

Comece lendo:

```bash
less docs/guia_lab.md
```

Depois rode:

```bash
make help
make show
make doctor
make sim
make waves
make synth
```

Se a biblioteca SAED nao estiver no caminho padrao, informe o caminho:

```bash
make synth SAED_REF=/caminho/para/ref
```
