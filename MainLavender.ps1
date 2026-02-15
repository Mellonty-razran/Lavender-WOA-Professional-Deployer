[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ProgressPreference = 'SilentlyContinue'
Clear-Host

$baseDir = Join-Path $HOME ".woa-lavender"
$adb = "$baseDir\adb\platform-tools\adb.exe"
$fastboot = "$baseDir\adb\platform-tools\fastboot.exe"
$dism = "$baseDir\dismbin\dism.exe"

# --- ДИСКЛЕЙМЕР ---
Write-Host "===============================================================" -ForegroundColor Red
Write-Host "                !!! ВНИМАНИЕ: ДИСКЛЕЙМЕР !!!" -ForegroundColor White -BackgroundColor Red
Write-Host "===============================================================" -ForegroundColor Red
Write-Host " Все действия вы выполняете на свой страх и риск!"
Write-Host " Автор скрипта и администрация 4PDA не несут ответственности за"
Write-Host " окирпиченные устройства, сгоревшие флешки или потерю данных."
Write-Host "===============================================================" -ForegroundColor Red
$confirm = Read-Host "Введите 'YES' (английскими буквами), чтобы продолжить"

if ($confirm -ne "YES") { 
    Write-Host "Выход из соображений безопасности..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    exit 
}

function Show-Header {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "   LAVENDER WOA: PROFESSIONAL DEPLOYER v1.0    " -ForegroundColor White -BackgroundColor Blue
    Write-Host "===============================================" -ForegroundColor Cyan
}

while($true) {
    Show-Header
    Write-Host ""
    Write-Host " [1] ПРОВЕРКА СТАТУСА" -ForegroundColor Yellow
    Write-Host " [2] ПРОШИТЬ TWRP"
    Write-Host " [3] ЗАГРУЗИТЬ UEFI (BOOT)"
    Write-Host " [4] РАЗМЕТКА ПАМЯТИ (PARTED)"
    Write-Host " [5] УСТАНОВКА WINDOWS (WIM/ESD)" -ForegroundColor Green
    Write-Host " [6] ВЫХОД"
    Write-Host ""
    
    $choice = Read-Host "Выберите пункт"

    switch ($choice) {
        "1" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ:" -ForegroundColor Cyan
            Write-Host "1. Подключите телефон к ПК."
            Write-Host "2. Включите 'Отладку по USB' в меню разработчика (для ADB)."
            Write-Host "3. Или переведите в Fastboot (Громкость вниз + Питание)."
            Write-Host "`n--- РЕЗУЛЬТАТ ---" -ForegroundColor Yellow
            Write-Host "ADB устройства:"
            & $adb devices
            Write-Host "Fastboot устройства:"
            & $fastboot devices
            Read-Host "`nНажмите Enter для возврата..."
        }
        
        "2" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ:" -ForegroundColor Cyan
            Write-Host "1. Переведите телефон в режим FASTBOOT (Заяц в шапке)."
            Write-Host "2. Убедитесь, что статус в п.1 показывает серийный номер."
            Write-Host "`nНачинаю прошивку TWRP..." -ForegroundColor Magenta
            & $fastboot flash recovery "$baseDir\files\twrp.img"
            Write-Host "`nГотово! Зажмите [Громкость Вверх + Питание] для входа в TWRP." -ForegroundColor Green
            Read-Host "`nНажмите Enter..."
        }

        "3" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ:" -ForegroundColor Cyan
            Write-Host "1. Телефон должен быть в режиме FASTBOOT."
            Write-Host "2. Эта команда НЕ прошивает UEFI, а только запускает его один раз."
            Write-Host "`nЗагрузка UEFI..." -ForegroundColor Green
            & $fastboot boot "$baseDir\files\uefi.img"
            Read-Host "`nНажмите Enter..."
        }

        "4" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ:" -ForegroundColor Cyan
            Write-Host "1. Зайдите в TWRP на телефоне."
            Write-Host "2. Перейдите в Advanced -> ADB Sideload (или просто оставьте в меню)."
            Write-Host "3. Скрипт попытается прочитать таблицу разделов."
            Write-Host "`n--- ТАБЛИЦА РАЗДЕЛОВ ---" -ForegroundColor Yellow
            & $adb shell "chmod +x /sdcard/parted && /sdcard/parted /dev/block/sda print"
            Write-Host "`nЕсли пусто — проверьте соединение ADB!" -ForegroundColor Red
            Read-Host "`nНажмите Enter..."
        }

        "5" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ (ВАЖНО):" -ForegroundColor Cyan
            Write-Host "1. В TWRP смонтируйте разделы Windows и Windows ESP как Mass Storage."
            Write-Host "2. Или используйте скрипт монтирования в самом TWRP."
            Write-Host "3. Узнайте букву диска в 'Моем компьютере' (например, D)."
            
            $imgPath = Read-Host "`nПеретащите сюда файл (.wim или .esd)"
            $imgPath = $imgPath.Trim('"')
            
            if (Test-Path $imgPath) {
                & $dism /Get-ImageInfo /ImageFile:$imgPath
                $index = Read-Host "`nВведите номер индекса (обычно 1)"
                $drive = Read-Host "Введите букву диска (БЕЗ двоеточия, например D)"
                
                Write-Host "`nРАЗВЕРТЫВАНИЕ ОБРАЗА... ЭТО ЗАЙМЕТ ВРЕМЯ." -ForegroundColor Magenta
                & $dism /Apply-Image /ImageFile:$imgPath /Index:$index /ApplyDir:$($drive + ":\") /CheckIntegrity
                
                if ($LASTEXITCODE -eq 0) { Write-Host "`nУСПЕШНО!" -ForegroundColor Green }
                else { Write-Host "`nОШИБКА!" -ForegroundColor Red }
            }
            Read-Host "`nНажмите Enter..."
        }

        "6" { exit }
    }
}
