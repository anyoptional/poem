Write-Host "=== Start Deploy Backend ===" -ForegroundColor Green

$archiveDir = ".archive"
$backendDir = "backend"

Write-Host "1. Zipping backend..." -ForegroundColor Yellow
Compress-Archive -Path "$backendDir\*" -DestinationPath "$archiveDir\zip_backend.zip" -Force
Write-Host "   backend is zipped" -ForegroundColor Green

Write-Host "=== End Deploy Backend ===" -ForegroundColor Green
