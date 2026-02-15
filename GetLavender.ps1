[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$baseDir = Join-Path $HOME ".woa-lavender"
$fDir    = Join-Path $baseDir "files"
$dDir    = Join-Path $baseDir "dismbin"
$aDir    = Join-Path $baseDir "adb"

# Создание папок
$paths = @($baseDir, $fDir, $dDir, $aDir)
foreach ($p in $paths) { if (-not (Test-Path $p)) { New-Item $p -ItemType Directory | Out-Null } }

# Прямые ссылки на твои ресурсы
$links = @{
    "platform-tools.zip" = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/platform-tools.zip"
    "dism-bin.zip"       = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/dism-bin.zip"
    "libwim-15.dll"      = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/libwim-15.dll"
    "uefi.img"           = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/uefi.img"
    "files\twrp.img"     = "https://github.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/releases/download/v1/twrp-3.7.0_9-0-lavender.img"
    "files\parted"       = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
}

# Функция отрисовки прогресс-бара (как ты просил)
function Download-WithVisualBar {
    param([string]$url, [string]$dest)
    $file = Split-Path $dest -Leaf
    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "Mozilla/5.0")
    $barLength = 30 
    
    $event = Register-ObjectEvent -InputObject $client -EventName DownloadProgressChanged -Action {
        $percent = $EventArgs.ProgressPercentage
        $totalMb = [math]::Round($EventArgs.TotalBytesToReceive / 1MB, 2)
        $curMb   = [math]::Round($EventArgs.BytesReceived / 1MB, 2)
        $done = [math]::Floor($percent / (100 / $barLength))
        $left = $barLength - $done
        $bar = "█" * $done + "░" * $left
        $statusString = "`r[+] Downloading $file [$bar] $percent% ($curMb / $totalMb MB)"
        Write-Host -NoNewline $statusString -ForegroundColor Yellow
    }

    $client.DownloadFileAsync($url, $dest)
    while ($client.IsBusy) { Start-Sleep -Milliseconds 50 }
    Write-Host "" 
    Unregister-Event -SourceIdentifier $event.Name
}

Clear-Host
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   ПОДГОТОВКА СРЕДЫ LAVENDER WOA              " -ForegroundColor White -BackgroundColor Blue
Write-Host "===============================================" -ForegroundColor Cyan

# Процесс загрузки
foreach ($name in $links.Keys) {
    $target = Join-Path $baseDir $name
    Download-WithVisualBar -url $links[$name] -dest $target
}

# Распаковка архивов
Write-Host "`n[!] Распаковка системных компонентов..." -ForegroundColor Cyan
if (Test-Path "$baseDir\platform-tools.zip") { 
    Expand-Archive "$baseDir\platform-tools.zip" $aDir -Force
    Remove-Item "$baseDir\platform-tools.zip" 
}
if (Test-Path "$baseDir\dism-bin.zip") { 
    Expand-Archive "$baseDir\dism-bin.zip" $dDir -Force
    Remove-Item "$baseDir\dism-bin.zip" 
}

Write-Host "`n>>> ВСЕ РЕСУРСЫ ГОТОВЫ. ЗАПУСК МЕНЮ... <<<" -ForegroundColor Green
Start-Sleep -Seconds 2

# Запуск MainLavender.ps1
irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1?v=$(Get-Random)" | iex
