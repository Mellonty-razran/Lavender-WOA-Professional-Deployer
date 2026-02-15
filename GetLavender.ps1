# LAVENDER-WOA BOOTSTRAPPER
Write-Host "Connecting to Lavender Professional Repository..." -ForegroundColor Cyan
$url = "https://raw.githubusercontent.com/Mellonty-razran/Lavender-WOA-Professional-Deployer/main/MainLavender.ps1"
irm $url | iex
