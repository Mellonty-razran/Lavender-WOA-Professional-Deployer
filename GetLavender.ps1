[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ProgressPreference = 'SilentlyContinue'

$baseDir = Join-Path $HOME ".woa-lavender"
if (-not (Test-Path $baseDir)) { New-Item $baseDir -ItemType Directory -Force | Out-Null }
foreach ($sub in "files","dismbin","adb") { 
    $p = Join-Path $baseDir $sub
    if (-not (Test-Path $p)) { New-Item $p -ItemType Directory -Force | Out-Null }
}

$links = @{
    "platform-tools.zip" = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/platform-tools.zip"
    "dism-bin.zip"       = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/dism-bin.zip"
    "uefi.img"           = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/files/uefi.img"
}

function Download-Direct {
    param([string]$url, [string]$dest)
    $file = Split-Path $dest -Leaf
    if (Test-Path $dest) { Remove-Item $dest -Force }

    $client = New-Object System.Net.WebClient
    $client.Headers.Add("User-Agent", "Mozilla/5.0")
    
    # Прямой вывод в консоль через системные средства
    [System.Console]::ForegroundColor = [System.ConsoleColor]::Cyan
    [System.Console]::WriteLine("[*] Starting download: $file")

    $client.DownloadFile($url, $dest) # Используем синхронную загрузку для надежности
    
    [System.Console]::ForegroundColor = [System.ConsoleColor]::Green
    [System.Console]::WriteLine("[OK] Finished: $file")
    [System.Console]::ResetColor()
}

[System.Console]::Clear()
[System.Console]::ForegroundColor = [System.ConsoleColor]::Cyan
[System.Console]::WriteLine("===============================================")
[System.Console]::WriteLine("   LAVENDER WOA: DOWNLOADING COMPONENTS       ")
[System.Console]::WriteLine("===============================================")

foreach ($key in $links.Keys) {
    $target = Join-Path $baseDir $key
    Download-Direct -url $links[$key] -dest $target
}

# Распаковка
[System.Console]::WriteLine("`n[!] Extracting files...")
Expand-Archive "$baseDir\platform-tools.zip" "$baseDir\adb" -Force
Expand-Archive "$baseDir\dism-bin.zip" "$baseDir\dismbin" -Force

# Переход к меню
irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1?v=$(Get-Random)" | iex
