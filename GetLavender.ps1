[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# 1. Пути в домашней директории
$cryoDir = Join-Path $HOME ".cryoslayer"
$filesDir = Join-Path $cryoDir "files"
$dismbinDir = Join-Path $cryoDir "dismbin"
$adbDir = Join-Path $cryoDir "adb"

Write-Host "[*] Подготовка папок в $HOME..." -ForegroundColor Cyan
foreach ($dir in @($cryoDir, $filesDir, $dismbinDir, $adbDir)) {
    if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory | Out-Null }
}

# 2. Ссылки (включая DISM и Platform Tools)
$files = @{
    "twrp.img" = "https://dl.twrp.me/lavender/twrp-3.7.0_9-0-lavender.img"
    "uefi.img" = "https://4pda.to/forum/dl/post/24126505/uefi.img"
    "parted"   = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
    "akershus.zip" = "https://github.com/edk2-porting/WOA-Drivers/releases/download/2210.1-fix/akershus.zip"
    "dism.zip" = "https://raw.githubusercontent.com/arkt-7/won-deployer/main/files/dism-bin.zip"
    "tools.zip" = "https://raw.githubusercontent.com/arkt-7/won-deployer/main/files/platform-tools.zip"
}

# 3. Загрузка и распаковка
foreach ($name in $files.Keys) {
    $target = if ($name.EndsWith(".zip")) { Join-Path $cryoDir $name } else { Join-Path $filesDir $name }
    if (-not (Test-Path $target)) {
        Write-Host "[+] Скачиваю $name..." -ForegroundColor Yellow
        Invoke-WebRequest -Uri $files[$name] -OutFile $target
    }
}

# Распаковка инструментов
if (Test-Path "$cryoDir\dism.zip") {
    Expand-Archive -Path "$cryoDir\dism.zip" -DestinationPath $dismbinDir -Force
    Remove-Item "$cryoDir\dism.zip"
}
if (Test-Path "$cryoDir\tools.zip") {
    Expand-Archive -Path "$cryoDir\tools.zip" -DestinationPath $adbDir -Force
    Remove-Item "$cryoDir\tools.zip"
}

# 4. Запуск основного скрипта
irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
