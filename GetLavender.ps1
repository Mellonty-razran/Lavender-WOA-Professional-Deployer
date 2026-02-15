[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$baseDir = Join-Path $HOME ".woa-lavender"
$paths = @($baseDir, "$baseDir\files", "$baseDir\dismbin", "$baseDir\adb")
foreach ($p in $paths) { if (-not (Test-Path $p)) { New-Item $p -ItemType Directory | Out-Null } }

$links = @{
    "platform-tools.zip" = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/platform-tools.zip"
    "dism-bin.zip"       = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/dism-bin.zip"
    "libwim-15.dll"      = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/libwim-15.dll"
    "uefi.img"           = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/uefi.img"
    "files\twrp.img"     = "https://github.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/releases/download/v1/twrp-3.7.0_9-0-lavender.img"
    "files\parted"       = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
}

# Функция для отрисовки бара
function Download-WithVisualBar {
    param([string]$url, [string]$dest)
    $file = Split-Path $dest -Leaf
    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "Mozilla/5.0")
    
    $start = Get-Date
    $received = 0
    
    # Это событие будет рисовать нам всё в консоли
    $event = Register-ObjectEvent -InputObject $client -EventName DownloadProgressChanged -Action {
        $prog = $EventArgs.ProgressPercentage
        $total = [math]::Round($EventArgs.TotalBytesToReceive / 1MB, 2)
        $cur = [math]::Round($EventArgs.BytesReceived / 1MB, 2)
        Write-Progress -Activity "СКАЧИВАНИЕ: $file" -Status "$cur MB из $total MB ($prog%)" -PercentComplete $prog
    }

    $task = $client.DownloadFileAsync($url, $dest)
    while ($client.IsBusy) { Start-Sleep -Milliseconds 100 }
    Unregister-Event -SourceIdentifier $event.Name
}

Write-Host "`n>>> ЗАПУСК ЗАГРУЗКИ РЕСУРСОВ <<<" -ForegroundColor Cyan

foreach ($name in $links.Keys) {
    $target = Join-Path $baseDir $name
    Download-WithVisualBar -url $links[$name] -dest $target
}

Write-Host "`n>>> РАСПАКОВКА <<<" -ForegroundColor Yellow
if (Test-Path "$baseDir\platform-tools.zip") { Expand-Archive "$baseDir\platform-tools.zip" "$baseDir\adb" -Force; Remove-Item "$baseDir\platform-tools.zip" }
if (Test-Path "$baseDir\dism-bin.zip") { Expand-Archive "$baseDir\dism-bin.zip" "$baseDir\dismbin" -Force; Remove-Item "$baseDir\dism-bin.zip" }

Write-Host "`n>>> ГОТОВО! ПЕРЕХОДИМ В МЕНЮ <<<" -ForegroundColor Green
irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1?v=$(Get-Random)" | iex
