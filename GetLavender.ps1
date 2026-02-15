[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Названия проекта и пути (Чистый WOA-Lavender)
$projName = "WOA-Lavender"
$baseDir  = Join-Path $HOME ".woa-lavender"
$fDir     = Join-Path $baseDir "files"
$dDir     = Join-Path $baseDir "dismbin"
$aDir     = Join-Path $baseDir "adb"

Write-Host ">>> $projName: РАЗВЕРТЫВАНИЕ ПРОФЕССИОНАЛЬНОЙ СРЕДЫ <<<" -ForegroundColor Cyan

# 1. Создаем структуру папок (Автоматически)
$paths = @($baseDir, $fDir, $dDir, $aDir)
foreach ($p in $paths) { 
    if (-not (Test-Path $p)) { 
        New-Item $p -ItemType Directory | Out-Null
        Write-Host "[+] Создана директория: $p" -ForegroundColor Gray
    } 
}

# 2. Ссылки компонентов (ТВОИ ЛИЧНЫЕ РЕСУРСЫ)
$links = @{
    # Теперь названия четко как у тебя в репо
    "dism-bin.zip"       = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/dism-bin.zip"
    "platform-tools.zip" = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/platform-tools.zip"
    "libwim-15.dll"      = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/libwim-15.dll"
    "uefi.img"           = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/uefi.img"
    
    # Твой TWRP из релизов
    "files\twrp.img"     = "https://github.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/releases/download/v1/twrp-3.7.0_9-0-lavender.img"
    
    # Тот самый "нож" для разделов памяти
    "files\parted"       = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
}

# И в блоке распаковки тоже поправим:
if (Test-Path "$baseDir\platform-tools.zip") {
    Write-Host "[*] Распаковка инструментов ADB в $aDir..." -ForegroundColor Gray
    Expand-Archive "$baseDir\platform-tools.zip" $aDir -Force
    Remove-Item "$baseDir\platform-tools.zip"
}

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

# 3. Умная загрузка
foreach ($file in $links.Keys) {
    $target = Join-Path $baseDir $file
    if (-not (Test-Path $target)) {
        Write-Host "[+] Установка компонента: $file" -ForegroundColor Yellow
        try { 
            $wc.DownloadFile($links[$file], $target) 
        } catch { 
            Write-Host " [!] Проблема с файлом $file. Проверь ссылку!" -ForegroundColor Red 
        }
    }
}

# 4. Распаковка архивов в правильные папки (Структура как в EXE)
Write-Host ">>> ФИНАЛЬНАЯ СБОРКА КОМПОНЕНТОВ <<<" -ForegroundColor Cyan

if (Test-Path "$baseDir\dism.zip") {
    Write-Host "[*] Конфигурация DISM..." -ForegroundColor Gray
    Expand-Archive "$baseDir\dism.zip" $dDir -Force
    Remove-Item "$baseDir\dism.zip"
}

if (Test-Path "$baseDir\adb.zip") {
    Write-Host "[*] Конфигурация ADB/Fastboot..." -ForegroundColor Gray
    Expand-Archive "$baseDir\adb.zip" $aDir -Force
    Remove-Item "$baseDir\adb.zip"
}

Write-Host ">>> СРЕДА ГОТОВА. ЗАПУСК $projName <<<" -ForegroundColor Green

# 5. Запуск
$exePath = Join-Path $baseDir "woa-lavender.exe"
if (Test-Path $exePath) {
    Start-Process $exePath
} else {
    Write-Host "[!] EXE не найден, запускаю интерфейс напрямую..." -ForegroundColor Yellow
    irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
}
