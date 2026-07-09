#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/maikonmichelalmeida/curso.git"
REPO_DIR="$HOME/curso"
BRANCH="main"

echo
echo "Atualizador do curso"
echo "Destino: $REPO_DIR"
echo

if [[ ! -d "$REPO_DIR/.git" ]]; then
    if [[ -e "$REPO_DIR" ]]; then
        echo "ERRO: $REPO_DIR existe, mas nao e um repositorio Git."
        echo "Renomeie ou remova essa pasta antes de clonar."
        exit 1
    fi

    echo "Clonando repositorio..."
    git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"

echo "Verificando alteracoes locais..."
if [[ -n "$(git status --porcelain)" ]]; then
    echo "ERRO: ha alteracoes locais no servidor."
    echo "Resolva ou salve essas alteracoes antes de atualizar:"
    git status --short
    exit 1
fi

echo "Atualizando..."
git fetch origin
git pull --ff-only origin "$BRANCH"

chmod +x atualizar_servidor.sh 2>/dev/null || true

echo
echo "Servidor atualizado com sucesso."
