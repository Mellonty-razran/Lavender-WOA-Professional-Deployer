Write-Host "Initializing CryoSlayer Professional Engine..." -ForegroundColor Cyan
$url = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1"
irm $url | iex
$downloads = @{
    # Твои прошлые ссылки
    "akershus.zip" = "https://github.com/edk2-porting/WOA-Drivers/releases/download/2210.1-fix/akershus.zip"
    "uefi.img"     = "https://4pda.to/forum/dl/post/24126505/uefi.img"
    "twrp.img"     = "https://dl.twrp.me/lavender/twrp-3.7.0_9-0-lavender.img"
    "parted"       = "https://github.com/pali/parted-static/raw/master/out/parted-arm64"
    
    # ПРЯМАЯ ССЫЛКА НА ОБРАЗ (Windows 11 Gamer Edition)
    "GamerEdition.esd" = "https://drive.usercontent.google.com/download?id=11UFTsnuyfgZyBsyYC31jl_FYLI__4q0p&export=download"
}
