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
    # Твои уже готовые файлы
    "dism.zip"       = "https://raw.githubusercontent.com/Mellonty-razran/files/main/dism-bin.zip"
    
    # Сюда вставь свою ссылку, когда зальешь platform-tools в свой репо
    "adb.zip"        = "https://raw.githubusercontent.com/Mellonty-razran/files/main/platform-tools.zip"
    
    # Остальные зависимости (залей их к себе в репо files)
    "libwim-15.dll"  = "https://raw.githubusercontent.com/Mellonty-razran/files/main/libwim-15.dll"
    "woa-lavender.exe" = "https://raw.githubusercontent.com/Mellonty-razran/files/main/woa-lavender.exe"

    # Официальные ресурсы
    "files\twrp.img" = "https://dl.twrp.me/lavender/twrp-3.7.0_9-0-lavender.img"
    "files\parted"   = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
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
