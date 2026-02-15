[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$ProgressPreference = 'SilentlyContinue'
Clear-Host

$baseDir = Join-Path $HOME ".woa-lavender"

function Find-Tool {
    param([string]$folder, [string]$exe)
    $path = Get-ChildItem -Path (Join-Path $baseDir $folder) -Filter $exe -Recurse | Select-Object -ExpandProperty FullName -First 1
    return $path
}

$adb = Find-Tool "adb" "adb.exe"
$fastboot = Find-Tool "adb" "fastboot.exe"
$dism = Find-Tool "dismbin" "dism.exe"
$twrp = Join-Path $baseDir "files\twrp.img"
$uefi = Join-Path $baseDir "files\uefi.img"

Write-Host "===============================================================" -ForegroundColor Red
Write-Host "                !!! ВНИМАНИЕ: ДИСКЛЕЙМЕР !!!" -ForegroundColor White -BackgroundColor Red
Write-Host "===============================================================" -ForegroundColor Red
Write-Host " Все действия вы выполняете на свой страх и риск!"
Write-Host " Автор скрипта и администрация 4PDA не несут ответственности за"
Write-Host " окирпиченные устройства, сгоревшие флешки или потерю данных."
Write-Host "===============================================================" -ForegroundColor Red
Write-Host " Скрины работы скоро будут (возможно), проект в активной бете."
Write-Host "===============================================================" -ForegroundColor Yellow
$confirm = Read-Host "Введите 'YES', чтобы продолжить"

if ($confirm -ne "YES") { exit }

function Show-Header {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "   LAVENDER WOA: PROFESSIONAL DEPLOYER v1.0    " -ForegroundColor White -BackgroundColor Blue
    Write-Host "===============================================" -ForegroundColor Cyan
}

while($true) {
    Show-Header
    Write-Host ""
    Write-Host " [1] ПРОВЕРКА СТАТУСА (ADB/Fastboot)" -ForegroundColor Yellow
    Write-Host " [2] ПРОШИТЬ TWRP"
    Write-Host " [3] ЗАГРУЗИТЬ UEFI (BOOT)"
    Write-Host " [4] ИНФО О РАЗДЕЛАХ (PARTED)"
    Write-Host " [5] УСТАНОВКА WINDOWS (WIM/ESD)" -ForegroundColor Green
    Write-Host " [6] ВЫХОД"
    Write-Host ""
    
    $choice = Read-Host "Выберите пункт"

    switch ($choice) {
        "1" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ:" -ForegroundColor Cyan
            Write-Host "Для ADB: Включите отладку по USB в системе."
            Write-Host "Для Fastboot: Зажмите [Громкость Вниз + Питание] на выключенном ТВ."
            Write-Host "`n--- РЕЗУЛЬТАТ ---" -ForegroundColor Yellow
            if ($adb) { Write-Host "ADB:"; & $adb devices }
            if ($fastboot) { Write-Host "Fastboot:"; & $fastboot devices }
            Read-Host "`nНажмите Enter..."
        }
        
        "2" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ:" -ForegroundColor Cyan
            Write-Host "1. Переведите телефон в режим FASTBOOT (заяц)."
            if ($fastboot -and (Test-Path $twrp)) {
                & $fastboot flash recovery $twrp
                Write-Host "`nГотово! Зажмите [Громкость Вверх + Питание] для входа." -ForegroundColor Green
            } else { Write-Host "Ошибка: Файлы не найдены!" -ForegroundColor Red }
            Read-Host "`nНажмите Enter..."
        }

        "3" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ:" -ForegroundColor Cyan
            Write-Host "1. Телефон должен быть в режиме FASTBOOT."
            if ($fastboot -and (Test-Path $uefi)) {
                & $fastboot boot $uefi
                Write-Host "`nЗагрузка UEFI..." -ForegroundColor Green
            } else { Write-Host "Ошибка: Файлы не найдены!" -ForegroundColor Red }
            Read-Host "`nНажмите Enter..."
        }

        "4" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ:" -ForegroundColor Cyan
            Write-Host "1. Зайдите в TWRP на телефоне."
            Write-Host "2. Убедитесь, что кабель подключен."
            Write-Host "`n--- ТАБЛИЦА РАЗДЕЛОВ ---" -ForegroundColor Yellow
            if ($adb) { & $adb shell "chmod +x /sdcard/parted && /sdcard/parted /dev/block/sda print" }
            Read-Host "`nНажмите Enter..."
        }

        "5" {
            Show-Header
            Write-Host "`n>>> ИНСТРУКЦИЯ:" -ForegroundColor Cyan
            Write-Host "1. В TWRP смонтируйте разделы как Mass Storage."
            Write-Host "2. Узнайте букву диска Windows (например, D)."
            
            $imgPath = (Read-Host "`nПеретащите сюда файл (.wim или .esd)").Trim('"')
            
            if (Test-Path $imgPath) {
                & $dism /Get-ImageInfo /ImageFile:$imgPath
                $index = Read-Host "`nВведите номер индекса (обычно 1)"
                $drive = Read-Host "Введите букву диска (например D)"
                
                Write-Host "`nРАЗВЕРТЫВАНИЕ ОБРАЗА... НЕ ЗАКРЫВАЙТЕ ОКНО!" -ForegroundColor Magenta
                & $dism /Apply-Image /ImageFile:$imgPath /Index:$index /ApplyDir:$($drive + ":\") /CheckIntegrity
                
                if ($LASTEXITCODE -eq 0) { Write-Host "`nУСПЕШНО!" -ForegroundColor Green }
                else { Write-Host "`nОШИБКА!" -ForegroundColor Red }
            }
            Read-Host "`nНажмите Enter..."
        }

        "6" { exit }
    }
}
