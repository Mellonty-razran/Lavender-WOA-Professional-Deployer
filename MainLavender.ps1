[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Header {
    Clear-Host
    # Твоё оригинальное лого Lavender
    $Logo = @"
  _                                     _            
 | |                                   | |           
 | |       __ _ __   __ ___ _ __   __| | ___ _ __  
 | |      / _` |\ \ / // _ \ '_ \ / _` |/ _ \ '__| 
 | |____ | (_| | \ V /|  __/ | | | (_| |  __/ |    
 |______| \__,_|  \_/  \___|_| |_|\__,_|\___|_|    
                                                   
 >> ULTIMATE WINDOWS ON ARM DEPLOYER FOR LAVENDER <<
=======================================================
   PROJECT: CRYOSLAYER | DEVELOPER: Mellonty-razran
=======================================================
"@
    Write-Host $Logo -ForegroundColor Cyan
}

# Пути как в won-deployer
$cryoDir = Join-Path $env:USERPROFILE ".cryoslayer"
$filesDir = Join-Path $cryoDir "files"
$dismExe = Join-Path $cryoDir "dismbin\Dism.exe"

while($true) {
    Show-Header
    Write-Host " [1] Проверка связи (Fastboot)"
    Write-Host " [2] Прошивка Recovery (TWRP)"
    Write-Host " [3] Подготовка Parted (Разметка)" -ForegroundColor Yellow
    Write-Host " [4] Установка Windows 11 (DISM)" -ForegroundColor Green
    Write-Host " [5] Установка драйверов (Akershus)" -ForegroundColor Green
    Write-Host " [6] Прошивка UEFI Bootloader" -ForegroundColor Cyan
    Write-Host " [Q] Выход"
    
    $choice = Read-Host "`nCryoSlayer > Выберите шаг"
    if ($choice -eq "q") { break }

    switch ($choice) {
        "1" { 
            Write-Host "[*] Поиск устройств..." -ForegroundColor Gray
            fastboot devices
            pause 
        }
        "2" { 
            Write-Host "[*] Прошивка TWRP..." -ForegroundColor Cyan
            fastboot flash recovery "$filesDir\twrp.img"
            pause 
        }
        "3" {
            Write-Host "[*] Отправка Parted на телефон..." -ForegroundColor Yellow
            adb push "$filesDir\parted" /sbin/
            adb shell "chmod 755 /sbin/parted"
            Write-Host "[OK] Parted готов. Используйте 'adb shell' для разметки." -ForegroundColor Green
            pause
        }
        "4" {
            Add-Type -AssemblyName System.Windows.Forms
            $f = New-Object System.Windows.Forms.OpenFileDialog
            $f.Title = "Выберите образ Windows (ESD/WIM)"
            if($f.ShowDialog() -eq "OK") {
                $drive = (Read-Host "Введите букву диска WINLAV (напр. D)").ToUpper() + ":"
                & $dismExe /Apply-Image /ImageFile:$f.FileName /Index:1 /ApplyDir:$drive /Compact
            }
        }
        "5" {
            $drive = (Read-Host "Введите букву диска WINLAV").ToUpper() + ":"
            Write-Host "[*] Установка драйверов Akershus..." -ForegroundColor Cyan
            & $dismExe /Image:$drive /Add-Driver /Driver:"$filesDir\drivers" /Recurse
            pause
        }
        "6" {
            Write-Host "[*] Прошивка UEFI..." -ForegroundColor Cyan
            fastboot flash boot "$filesDir\uefi.img"
            pause
        }
    }
}
