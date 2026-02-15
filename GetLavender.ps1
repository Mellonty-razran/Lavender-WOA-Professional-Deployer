[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ProgressPreference = 'SilentlyContinue'

$baseDir = Join-Path $HOME ".woa-lavender"

# Создаем структуру (форсированно)
$paths = @($baseDir, "$baseDir\files", "$baseDir\dismbin", "$baseDir\adb")
foreach ($p in $paths) { if (-not (Test-Path $p)) { New-Item $p -ItemType Directory -Force | Out-Null } }

$links = @{
    "platform-tools.zip" = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/platform-tools.zip"
    "dism-bin.zip"       = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/dism-bin.zip"
    "libwim-15.dll"      = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/libwim-15.dll"
    "uefi.img"           = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/uefi.img"
    "files\twrp.img"     = "https://github.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/releases/download/v1/twrp-3.7.0_9-0-lavender.img"
    "files\parted"       = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
}

function Download-CustomBar {
    param([string]$url, [string]$dest)
    $file = Split-Path $dest -Leaf
    
    # Если мы тестим и хотим видеть бар — удаляем старый файл перед качкой
    if (Test-Path $dest) { Remove-Item $dest -Force }

    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "Mozilla/5.0")
    $width = 30 
    
    # Очистка старых событий, чтобы не было глюков
    Get-EventSubscriber | Unregister-Event -ErrorAction SilentlyContinue

    $event = Register-ObjectEvent -InputObject $client -EventName DownloadProgressChanged -Action {
        $p = $EventArgs.ProgressPercentage
        $total = [math]::Round($EventArgs.TotalBytesToReceive / 1MB, 2)
        $cur = [math]::Round($EventArgs.BytesReceived / 1MB, 2)
        
        $done = [math]::Floor($p / (100 / $width))
        $left = $width - $done
        $bar = "█" * $done + "░" * $left
        
        $msg = "`r[*] Downloading $file [$bar] $p% ($cur / $total MB)"
        Write-Host -NoNewline $msg -ForegroundColor Cyan
    }

    try {
        $client.DownloadFileAsync($url, $dest)
        while ($client.IsBusy) { Start-Sleep -Milliseconds 50 }
    } finally {
        Write-Host "" 
        Unregister-Event -SourceIdentifier $event.Name -ErrorAction SilentlyContinue
        $client.Dispose()
    }
}

Clear-Host
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   LAVENDER WOA: ЗАГРУЗКА КОМПОНЕНТОВ          " -ForegroundColor White -BackgroundColor Blue
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host ""

foreach ($key in $links.Keys) {
    $target = Join-Path $baseDir $key
    Download-CustomBar -url $links[$key] -dest $target
}

Write-Host "`n[!] Распаковка и настройка..." -ForegroundColor Yellow
if (Test-Path "$baseDir\platform-tools.zip") { Expand-Archive "$baseDir\platform-tools.zip" "$baseDir\adb" -Force; Remove-Item "$baseDir\platform-tools.zip" }
if (Test-Path "$baseDir\dism-bin.zip") { Expand-Archive "$baseDir\dism-bin.zip" "$baseDir\dismbin" -Force; Remove-Item "$baseDir\dism-bin.zip" }

Write-Host "`n>>> ВСЁ ГОТОВО! ПЕРЕХОД К МЕНЮ... <<<" -ForegroundColor Green
Start-Sleep -Seconds 1

irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1?v=$(Get-Random)" | iex
