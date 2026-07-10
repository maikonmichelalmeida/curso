# ==============================================================================
# Lab 03 - Makefile de orientacao
# ==============================================================================
#
# Este Makefile fica na raiz do Lab 03 apenas para evitar a confusao de rodar
# `make help` ou `make doctor` no diretorio errado.
#
# A execucao real esta separada em:
#
#   simulation/  -> VCS/Verdi
#   synthesis/   -> Design Compiler/DC NXT

.PHONY: help doctor sim-help syn-help

help:
	@echo "Lab 03 - escolha uma frente de trabalho"
	@echo
	@echo "1) Simulacao RTL:"
	@echo "   module load vcs/W-2024.09-SP2-3 verdi/W-2024.09-SP2-6"
	@echo "   cd simulation"
	@echo "   make doctor"
	@echo "   make test"
	@echo
	@echo "2) Sintese/constraints:"
	@echo "   carregue o modulo do Design Compiler/DC NXT do servidor"
	@echo "   cd synthesis"
	@echo "   make doctor"
	@echo "   make syn LEVEL=0"
	@echo
	@echo "Atalhos:"
	@echo "   make sim-help"
	@echo "   make syn-help"

doctor: help

sim-help:
	@$(MAKE) --no-print-directory -C simulation help

syn-help:
	@$(MAKE) --no-print-directory -C synthesis help
