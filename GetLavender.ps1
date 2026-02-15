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

Write-Host "`n>>> ПОДГОТОВКА РЕСУРСОВ LAVENDER <<<" -ForegroundColor Cyan

foreach ($file in $links.Keys) {
    $target = Join-Path $baseDir $file
    Write-Host "[+] Загрузка: $file" -ForegroundColor Yellow
    try {
        # BITS Transfer — рисует бар автоматически!
        Start-BitsTransfer -Source $links[$file] -Destination $target -DisplayName "Скачивание $file"
    } catch {
        # Если BITS не сработал (редко), качаем обычным способом
        (New-Object System.Net.WebClient).DownloadFile($links[$file], $target)
    }
}

Write-Host "`n>>> РАСПАКОВКА КОМПОНЕНТОВ <<<" -ForegroundColor Cyan
if (Test-Path "$baseDir\platform-tools.zip") { Expand-Archive "$baseDir\platform-tools.zip" "$baseDir\adb" -Force; Remove-Item "$baseDir\platform-tools.zip" }
if (Test-Path "$baseDir\dism-bin.zip") { Expand-Archive "$baseDir\dism-bin.zip" "$baseDir\dismbin" -Force; Remove-Item "$baseDir\dism-bin.zip" }

Write-Host "`n>>> ВСЁ ГОТОВО! <<<" -ForegroundColor Green
Start-Sleep -Seconds 1

# ЗАПУСК МЕНЮ (Убедись, что MainLavender.ps1 не пустой!)
irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1?v=$(Get-Random)" | iex
