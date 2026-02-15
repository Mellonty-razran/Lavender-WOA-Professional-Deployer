[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$cryoDir = Join-Path $HOME ".cryoslayer"
$filesDir = Join-Path $cryoDir "files"
$dismExe = Join-Path $cryoDir "dismbin\Dism.exe"
# Добавляем ADB/Fastboot в текущую сессию
$env:Path += ";$cryoDir\adb"

function Show-Header {
    Clear-Host
    $Logo = @"
  _                                     _            
 | |                                   | |           
 | |       __ _ __   __ ___ _ __   __| | ___ _ __  
 | |      / _` |\ \ / // _ \ '_ \ / _` |/ _ \ '__| 
 | |____ | (_| | \ V /|  __/ | | | (_| |  __/ |    
 |______| \__,_|  \_/  \___|_| |_|\__,_|\___|_|    
                                                   
 >> ULTIMATE WINDOWS ON ARM DEPLOYER FOR LAVENDER <<
=======================================================
   PROJECT: CRYOSLAYER | HOME: $cryoDir
=======================================================
"@
    Write-Host $Logo -ForegroundColor Cyan
}

while($true) {
    Show-Header
    Write-Host " [1] Проверка Fastboot"
    Write-Host " [2] Прошить TWRP"
    Write-Host " [3] Подготовка Parted" -ForegroundColor Yellow
    Write-Host " [4] УСТАНОВКА WINDOWS" -ForegroundColor Green
    Write-Host " [5] УСТАНОВКА ДРАЙВЕРОВ" -ForegroundColor Green
    Write-Host " [6] Прошить UEFI" -ForegroundColor Cyan
    Write-Host " [Q] Выход"

    $choice = Read-Host "`nCryoSlayer > Выберите шаг"
    if ($choice -eq "q") { break }

    switch ($choice) {
        "1" { fastboot devices; pause }
        "2" { fastboot flash recovery "$filesDir\twrp.img"; pause }
        "3" {
            adb push "$filesDir\parted" /sbin/
            adb shell "chmod 755 /sbin/parted"
            Write-Host "[OK] Parted готов в телефоне." -ForegroundColor Green
            pause
        }
        "4" {
            Add-Type -AssemblyName System.Windows.Forms
            $f = New-Object System.Windows.Forms.OpenFileDialog
            if($f.ShowDialog() -eq "OK") {
                $drive = (Read-Host "Буква диска WINLAV (напр. D)").ToUpper() + ":"
                & $dismExe /Apply-Image /ImageFile:$f.FileName /Index:1 /ApplyDir:$drive /Compact
            }
        }
        "5" {
            $drive = (Read-Host "Буква диска WINLAV").ToUpper() + ":"
            # Распаковка драйверов если еще не распакованы
            if (-not (Test-Path "$filesDir\drivers")) {
                Expand-Archive -Path "$filesDir\akershus.zip" -DestinationPath "$filesDir\drivers" -Force
            }
            & $dismExe /Image:$drive /Add-Driver /Driver:"$filesDir\drivers" /Recurse
            pause
        }
        "6" { fastboot flash boot "$filesDir\uefi.img"; pause }
    }
}
