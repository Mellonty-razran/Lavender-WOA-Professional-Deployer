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

Write-Host "`n--- WOA-LAVENDER: СКАЧИВАНИЕ РЕСУРСОВ ---" -ForegroundColor Cyan

# Функция для скачивания с прогресс-баром
function Download-FileWithProgress {
    param([string]$url, [string]$destination)
    $pc = New-Object System.Net.WebClient
    $pc.Headers.Add("User-Agent", "Mozilla/5.0")
    
    # Подключаем событие для отслеживания прогресса
    $onProgress = {
        param($s, $e)
        $percent = $e.ProgressPercentage
        $downloadedMb = [math]::Round($e.BytesReceived / 1MB, 2)
        $totalMb = [math]::Round($e.TotalBytesToReceive / 1MB, 2)
        
        Write-Progress -Activity "Загрузка: $(Split-Path $destination -Leaf)" `
                       -Status "$percent% ($downloadedMb MB из $totalMb MB)" `
                       -PercentComplete $percent
    }
    $pc.add_DownloadProgressChanged($onProgress)
    $pc.DownloadFileAsync((New-Object Uri($url)), $destination)
    
    # Ждем завершения
    while ($pc.IsBusy) { Start-Sleep -Milliseconds 100 }
}

foreach ($file in $links.Keys) {
    $target = Join-Path $baseDir $file
    try { 
        Download-FileWithProgress -url $links[$file] -destination $target 
    } catch { 
        Write-Host " [!] Ошибка при загрузке $file" -ForegroundColor Red 
    }
}

Write-Host "`n--- РАСПАКОВКА И НАСТРОЙКА ---" -ForegroundColor Cyan
# Тут твоя распаковка...
Expand-Archive "$baseDir\platform-tools.zip" "$baseDir\adb" -Force
Expand-Archive "$baseDir\dism-bin.zip" "$baseDir\dismbin" -Force

Write-Host "`n--- ГОТОВО! ЗАПУСКАЕМ МЕНЮ ---" -ForegroundColor Green
irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
