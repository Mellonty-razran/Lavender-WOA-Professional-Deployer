[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# --- ПУТИ ---
$cryoDir = Join-Path $HOME ".cryoslayer"
$filesDir = Join-Path $cryoDir "files"
$logFile = Join-Path $cryoDir "cryoslayer.log"
$dismExe = Join-Path $cryoDir "dismbin\Dism.exe"
$env:Path += ";$cryoDir\adb"

# --- СИСТЕМА ЛОГИРОВАНИЯ ---
function Write-Log {
    param (
        [Parameter(Mandatory=$true)] [string]$Message,
        [Parameter(Mandatory=$false)] [string]$Level = "INFO", # INFO, WARN, ERROR
        [Parameter(Mandatory=$false)] [ConsoleColor]$Color = "White"
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Level] $Message"
    
    # Пишем в файл
    Add-Content -Path $logFile -Value $logEntry
    
    # Пишем в консоль
    Write-Host " [$Level] " -NoNewline -ForegroundColor $Color
    Write-Host $Message
}

# Очистка старого лога при запуске
"--- CryoSlayer Session Started $(Get-Date) ---" | Out-File $logFile

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
   LOGS: $logFile
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
    Write-Host " [L] Открыть файл логов" -ForegroundColor Gray
    Write-Host " [Q] Выход"

    $choice = Read-Host "`nCryoSlayer >"
    if ($choice -eq "q") { break }

    switch ($choice) {
        "1" {
            Write-Log "Запущена проверка устройств..." "INFO" "Cyan"
            $devs = fastboot devices
            if ($devs) { Write-Log "Устройство найдено: $devs" "INFO" "Green" }
            else { Write-Log "Устройства не найдены в Fastboot!" "ERROR" "Red" }
            pause 
        }

        "2" {
            Write-Log "Начало прошивки TWRP..." "INFO" "Cyan"
            if (Test-Path "$filesDir\twrp.img") {
                fastboot flash recovery "$filesDir\twrp.img" 2>&1 | Out-File -FilePath $logFile -Append
                Write-Log "Команда прошивки выполнена." "INFO" "Green"
            } else { Write-Log "Файл twrp.img отсутствует!" "ERROR" "Red" }
            pause
        }

        "3" {
            Write-Log "Отправка Parted в устройство..." "INFO" "Yellow"
            adb push "$filesDir\parted" /sbin/ 2>> $logFile
            adb shell "chmod 755 /sbin/parted" 2>> $logFile
            Write-Log "Parted готов к работе." "INFO" "Green"
            pause
        }

        "4" {
            Write-Log "Запуск развертывания Windows..." "INFO" "Green"
            Add-Type -AssemblyName System.Windows.Forms
            $f = New-Object System.Windows.Forms.OpenFileDialog
            if($f.ShowDialog() -eq "OK") {
                $drive = (Read-Host "Буква диска (напр. D)").ToUpper() + ":"
                Write-Log "Применяю образ $($f.FileName) на диск $drive" "INFO" "Cyan"
                & $dismExe /Apply-Image /ImageFile:$f.FileName /Index:1 /ApplyDir:$drive /Compact | Tee-Object -FilePath $logFile -Append
                Write-Log "Развертывание завершено." "INFO" "Green"
            }
            pause
        }

        "5" {
            $drive = (Read-Host "Буква диска").ToUpper() + ":"
            Write-Log "Начало установки драйверов на $drive..." "INFO" "Green"
            if (-not (Test-Path "$filesDir\drivers")) {
                Write-Log "Распаковка драйверов Akershus..." "INFO" "Gray"
                Expand-Archive "$filesDir\akershus.zip" "$filesDir\drivers" -Force
            }
            & $dismExe /Image:$drive /Add-Driver /Driver:"$filesDir\drivers" /Recurse | Tee-Object -FilePath $logFile -Append
            Write-Log "Инъекция драйверов завершена." "INFO" "Green"
            pause
        }

        "6" {
            Write-Log "Прошивка UEFI Bootloader..." "INFO" "Cyan"
            fastboot flash boot "$filesDir\uefi.img" 2>&1 | Out-File -FilePath $logFile -Append
            Write-Log "UEFI прошит." "INFO" "Green"
            pause
        }

        "l" {
            if (Test-Path $logFile) { Start-Process notepad.exe $logFile }
        }
    }
}
