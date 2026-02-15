[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$projDir = Join-Path $HOME ".cryoslayer"
$filesDir = Join-Path $projDir "files"
$dismExe = Join-Path $projDir "dismbin\Dism.exe"
$env:Path += ";$projDir\adb"

function Show-Header {
    Clear-Host
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "   CRYOSLAYER - PROFESSIONAL DEPLOYER FOR LAVENDER     " -ForegroundColor White
    Write-Host "   Version: 3.5 Diamond Build | Dev: Mellonty-razran   " -ForegroundColor Cyan
    Write-Host "=======================================================" -ForegroundColor Cyan
}

# Логика меню... (оставляем твое красивое меню с логами, которое мы писали выше)
