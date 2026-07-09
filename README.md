# curso

Este repositorio passa a ser o posto de trabalho principal para os labs do curso RTL/Synopsys.

A ideia e manter pequenos projetos independentes, em ordem de estudo:

```text
curso/
  01/
  02/
  03/
  ...
```

Cada pasta deve nascer com um objetivo claro, por exemplo:

- estudar uma tecnica de SystemVerilog;
- rodar uma simulacao VCS;
- abrir waveform no Verdi;
- testar uma constraint SDC;
- sintetizar com DC NXT;
- comparar RTL e gate-level;
- preparar Formality quando chegar a hora.

O LAB2 antigo fica congelado como referencia. A partir de agora, o desenvolvimento novo acontece aqui.

## Fluxo local

No Windows, use:

```bat
enviar_curso.bat
```

ou, se quiser escolher a mensagem:

```bat
enviar_curso.bat "mensagem do commit"
```

## Fluxo no servidor

Depois do primeiro clone no SSH, a pasta esperada e:

```text
/home/ciexpert/maikon.almeida/curso
```

Para atualizar no servidor:

```bash
cd ~/curso
./atualizar_servidor.sh
```

## Primeiro clone no servidor

Se `~/curso` ainda nao existir no servidor:

```bash
cd ~
git clone https://github.com/maikonmichelalmeida/curso.git curso
cd curso
chmod +x atualizar_servidor.sh
```
