[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Названия
$projName = "WOA-Lavender"
$baseDir  = Join-Path $HOME ".woa-lavender"
$fDir     = Join-Path $baseDir "files"
$dDir     = Join-Path $baseDir "dismbin"
$aDir     = Join-Path $baseDir "adb"

# ИСПРАВЛЕНО: Добавлены скобки ${}, чтобы PowerShell не тупил на двоеточии
Write-Host ">>> ${projName} - РАЗВЕРТЫВАНИЕ СРЕДЫ <<<" -ForegroundColor Cyan

# Создаем структуру папок
$paths = @($baseDir, $fDir, $dDir, $aDir)
foreach ($p in $paths) { 
    if (-not (Test-Path $p)) { 
        New-Item $p -ItemType Directory | Out-Null
    } 
}

# Твои прямые ссылки
$links = @{
    "dism-bin.zip"       = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/dism-bin.zip"
    "platform-tools.zip" = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/platform-tools.zip"
    "libwim-15.dll"      = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/libwim-15.dll"
    "uefi.img"           = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/uefi.img"
    "files\twrp.img"     = "https://github.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/releases/download/v1/twrp-3.7.0_9-0-lavender.img"
    "files\parted"       = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
}

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

# Скачивание
foreach ($file in $links.Keys) {
    $target = Join-Path $baseDir $file
    Write-Host "[+] Загрузка: $file" -ForegroundColor Yellow
    try { $wc.DownloadFile($links[$file], $target) } catch { Write-Host " [!] Ошибка при скачивании $file" -ForegroundColor Red }
}

# Распаковка
Write-Host ">>> ФИНАЛЬНАЯ СБОРКА <<<" -ForegroundColor Cyan

if (Test-Path "$baseDir\dism-bin.zip") {
    Expand-Archive "$baseDir\dism-bin.zip" $dDir -Force
    Remove-Item "$baseDir\dism-bin.zip"
}

if (Test-Path "$baseDir\platform-tools.zip") {
    Expand-Archive "$baseDir\platform-tools.zip" $aDir -Force
    Remove-Item "$baseDir\platform-tools.zip"
}

Write-Host ">>> ГОТОВО! ЗАПУСКАЕМ МЕНЮ... <<<" -ForegroundColor Green

# Запуск Main (Проверь, что этот файл есть в репо!)
irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
