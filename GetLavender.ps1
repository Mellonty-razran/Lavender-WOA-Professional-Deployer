[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$cryoDir = Join-Path $HOME ".cryoslayer"
$filesDir = Join-Path $cryoDir "files"
$dismbinDir = Join-Path $cryoDir "dismbin"
$adbDir = Join-Path $cryoDir "adb"

Write-Host "[*] Подготовка среды в $HOME..." -ForegroundColor Cyan
foreach ($dir in @($cryoDir, $filesDir, $dismbinDir, $adbDir)) {
    if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory | Out-Null }
}

# Список файлов, которые качаются без проблем (GitHub/Direct)
$directFiles = @{
    "parted"   = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
    "akershus.zip" = "https://github.com/edk2-porting/WOA-Drivers/releases/download/2210.1-fix/akershus.zip"
    "dism.zip" = "https://raw.githubusercontent.com/arkt-7/won-deployer/main/files/dism-bin.zip"
    "tools.zip" = "https://raw.githubusercontent.com/arkt-7/won-deployer/main/files/platform-tools.zip"
    "twrp.img" = "https://dl.twrp.me/lavender/twrp-3.7.0_9-0-lavender.img"
}

$wc = New-Object System.Net.WebClient
# Маскируемся под обычный браузер Chrome
$wc.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36")

foreach ($name in $directFiles.Keys) {
    $target = if ($name.EndsWith(".zip")) { Join-Path $cryoDir $name } else { Join-Path $filesDir $name }
    
    if (-not (Test-Path $target)) {
        Write-Host "[+] Загрузка $name..." -ForegroundColor Yellow
        try {
            $wc.DownloadFile($directFiles[$name], $target)
        } catch {
            Write-Host "[-] Ошибка при скачивании $name. Попробую через системный метод..." -ForegroundColor Gray
            Invoke-WebRequest -Uri $directFiles[$name] -OutFile $target -UserAgent "Mozilla/5.0"
        }
    }
}

# Отдельная обработка для UEFI (так как 4PDA блокирует скрипты)
if (-not (Test-Path "$filesDir\uefi.img")) {
    Write-Host "[!] ВНИМАНИЕ: Нужно скачать UEFI вручную (4PDA блокирует авто-загрузку)." -ForegroundColor Red
    Write-Host "[*] Сейчас откроется страница. Скачайте uefi.img и положите в $filesDir" -ForegroundColor Yellow
    Start-Process "https://4pda.to/forum/index.php?showtopic=944514" # Ссылка на тему
    pause
}

# Распаковка
Write-Host "[*] Распаковка инструментов..." -ForegroundColor Cyan
if (Test-Path "$cryoDir\dism.zip") { Expand-Archive "$cryoDir\dism.zip" $dismbinDir -Force; Remove-Item "$cryoDir\dism.zip" }
if (Test-Path "$cryoDir\tools.zip") { Expand-Archive "$cryoDir\tools.zip" $adbDir -Force; Remove-Item "$cryoDir\tools.zip" }

# Запуск ядра
irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
