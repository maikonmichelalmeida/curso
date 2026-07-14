# ==============================================================================
# Curso - Makefile de orientacao
# ==============================================================================
#
# Este arquivo existe para evitar um erro comum: rodar `make doctor` na raiz do
# repositorio e receber "No rule to make target 'doctor'".
#
# Os labs mantem seus Makefiles dentro das pastas especificas. Este Makefile da
# raiz apenas mostra para onde ir.

.PHONY: help doctor lab03-help

help:
	@echo "Curso - escolha o laboratorio e a etapa"
	@echo
	@echo "Lab 02B - introducao manual a sintese:"
	@echo "  leia: ~/curso/02B/README.md"
	@echo "  roteiro: ~/curso/02B/synthesis/roteiro_manual_dc_shell.md"
	@echo "  nao ha Makefile de sintese neste lab"
	@echo
	@echo "Lab 03 - simulacao RTL:"
	@echo "  cd ~/curso/03/simulation"
	@echo "  make doctor"
	@echo "  make test"
	@echo
	@echo "Lab 03 - sintese com Design Compiler:"
	@echo "  cd ~/curso/03/synthesis"
	@echo "  make doctor"
	@echo "  make syn LEVEL=0"
	@echo
	@echo "Para ver a ajuda especifica do Lab 03:"
	@echo "  cd ~/curso/03"
	@echo "  make help"

doctor: help

lab03-help:
	@$(MAKE) --no-print-directory -C 03 help
