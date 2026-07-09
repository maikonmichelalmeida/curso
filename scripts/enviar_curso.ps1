param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]] $MensagemPartes
)

$ErrorActionPreference = "Stop"

$RepoDir = Split-Path -Parent $PSScriptRoot
$RemoteUrl = "https://github.com/maikonmichelalmeida/curso.git"
$Branch = "main"

if ($MensagemPartes -and $MensagemPartes.Count -gt 0) {
    $Mensagem = ($MensagemPartes -join " ").Trim()
} else {
    $Mensagem = "Atualiza curso"
}

Set-Location $RepoDir

Write-Host ""
Write-Host "Projeto curso:"
Write-Host $RepoDir
Write-Host ""

if (!(Test-Path ".git")) {
    throw "Esta pasta ainda nao esta inicializada como Git. Rode a configuracao inicial primeiro."
}

$nestedGit = Get-ChildItem -Force -Recurse -Directory -Filter ".git" |
    Where-Object { $_.FullName -ne (Join-Path $RepoDir ".git") }

if ($nestedGit) {
    Write-Host "ERRO: ha repositorios Git aninhados dentro de curso:"
    $nestedGit | ForEach-Object { Write-Host "  $($_.FullName)" }
    throw "Remova ou mova esses .git antes de enviar."
}

$largeFiles = Get-ChildItem -Force -Recurse -File |
    Where-Object {
        $_.FullName -notmatch "\\.git\\" -and
        $_.Length -ge 95MB
    }

if ($largeFiles) {
    Write-Host "ERRO: arquivos grandes demais para GitHub:"
    $largeFiles | ForEach-Object {
        Write-Host ("  {0:N2} MB  {1}" -f ($_.Length / 1MB), $_.FullName)
    }
    throw "GitHub rejeita arquivos acima de 100 MB. Ajuste o .gitignore ou remova esses arquivos."
}

$origin = git remote get-url origin 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrWhiteSpace($origin)) {
    git remote add origin $RemoteUrl
} elseif ($origin.Trim() -ne $RemoteUrl) {
    Write-Host "Ajustando origin:"
    Write-Host "  antigo: $origin"
    Write-Host "  novo:   $RemoteUrl"
    git remote set-url origin $RemoteUrl
}

git branch -M $Branch

$status = git status --porcelain
if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "Nenhuma alteracao local para commit."
} else {
    Write-Host "Alteracoes encontradas:"
    git status --short
    Write-Host ""
    Write-Host "Registrando arquivos novos, alterados e removidos..."
    git add -A
    git commit -m $Mensagem
}

Write-Host ""
Write-Host "Enviando para GitHub..."
git push -u origin $Branch

Write-Host ""
Write-Host "Curso enviado com sucesso."
Write-Host ""
Write-Host "No servidor, use:"
Write-Host "  cd ~/curso"
Write-Host "  ./atualizar_servidor.sh"
