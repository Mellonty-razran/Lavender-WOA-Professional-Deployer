Clear-Host
$baseDir = Join-Path $HOME ".woa-lavender"
$adb     = Join-Path $baseDir "adb\platform-tools\adb.exe"
$fastboot = Join-Path $baseDir "adb\platform-tools\fastboot.exe"

Write-Host "===============================================" -ForegroundColor Cyan
Write-Host "   LAVENDER WOA PROFESSIONAL DEPLOYER v1.0    " -ForegroundColor White -BackgroundColor Blue
Write-Host "===============================================" -ForegroundColor Cyan
Write-Host " [1] Проверить подключение устройства (ADB)"
Write-Host " [2] Перезагрузить в Bootloader (Fastboot)"
Write-Host " [3] Прошить TWRP Recovery"
Write-Host " [4] Загрузить UEFI (Lavender-Port)"
Write-Host " [5] Выход"
Write-Host "===============================================" -ForegroundColor Cyan

$choice = Read-Host "Выберите действие"

switch ($choice) {
    "1" { 
        Write-Host "Поиск устройств..." -ForegroundColor Yellow
        & $adb devices
        Pause
        & irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
    }
    "2" { 
        Write-Host "Перезагрузка..." -ForegroundColor Yellow
        & $adb reboot bootloader
        & irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
    }
    "3" {
        $twrpPath = Join-Path $baseDir "files\twrp.img"
        Write-Host "Прошивка TWRP..." -ForegroundColor Magenta
        & $fastboot flash recovery $twrpPath
        Pause
        & irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
    }
    "4" {
        $uefiPath = Join-Path $baseDir "files\uefi.img"
        Write-Host "Запуск UEFI..." -ForegroundColor Green
        & $fastboot boot $uefiPath
        Pause
        & irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex
    }
    "5" { exit }
    default { Write-Host "Неверный выбор!"; Start-Sleep -Seconds 2; & irm "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1" | iex }
}
