[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$projName = "CryoSlayer"
$projDir = Join-Path $HOME ".cryoslayer"
$filesDir = Join-Path $projDir "files"
$dismbinDir = Join-Path $projDir "dismbin"
$adbDir = Join-Path $projDir "adb"

Write-Host "[*] Развертывание среды $projName..." -ForegroundColor Cyan

# Создание структуры как у профессиональных деплойеров
$dirs = @($projDir, $filesDir, $dismbinDir, $adbDir)
foreach ($dir in $dirs) {
    if (-not (Test-Path $dir)) { New-Item -Path $dir -ItemType Directory | Out-Null }
}

# Список файлов для твоего проекта (DLL берем чистые, без привязки к автору)
$components = @{
    "cryoslayer.exe"    = "ССЫЛКА_НА_ТВОЙ_EXE" 
    "libwim-15.dll"     = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/libwim-15.dll"
    "files\twrp.img"    = "https://dl.twrp.me/lavender/twrp-3.7.0_9-0-lavender.img"
    "files\parted"      = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
    "dism.zip"          = "https://raw.githubusercontent.com/Mellonty-razran/files/main/dism-bin.zip"
    "tools.zip"         = "https://raw.githubusercontent.com/Mellonty-razran/files/main/platform-tools.zip"
}

$wc = New-Object System.Net.WebClient
$wc.Headers.Add("User-Agent", "Mozilla/5.0")

foreach ($name in $components.Keys) {
    $targetPath = Join-Path $projDir $name
    if (-not (Test-Path $targetPath)) {
        Write-Host "[+] Установка компонента: $name" -ForegroundColor Yellow
        try { $wc.DownloadFile($components[$name], $targetPath) } catch { }
    }
}

# Распаковка ресурсов
if (Test-Path "$projDir\dism.zip") { Expand-Archive "$projDir\dism.zip" $dismbinDir -Force; Remove-Item "$projDir\dism.zip" }
if (Test-Path "$projDir\tools.zip") { Expand-Archive "$projDir\tools.zip" $adbDir -Force; Remove-Item "$projDir\tools.zip" }

Write-Host "[OK] Среда CryoSlayer готова." -ForegroundColor Green

# Запуск основного интерфейса
irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
