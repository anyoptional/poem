Write-Host "=== Start Deploy Frontend===" -ForegroundColor Green

$archiveDir = ".archive"
$webBuildDir = "frontend/build/web"

# 1. 打包前端项目
Write-Host "1. Building Flutter web..." -ForegroundColor Yellow
Set-Location frontend
$flutterBuildResult = flutter build web --release
if ($LASTEXITCODE -ne 0)
{
    Write-Host "   Flutter web build failed!" -ForegroundColor Red
    Write-Host $flutterBuildResult
    exit 1
}
Write-Host "   Flutter web build succeed" -ForegroundColor Green
Set-Location ..

# 2. 压缩成zip包
Write-Host "2. Zipping frontend/build/web..." -ForegroundColor Yellow
Compress-Archive -Path "$webBuildDir\*" -DestinationPath "$archiveDir\zip_frontend.zip" -Force
Write-Host "   frontend/build/web is zipped" -ForegroundColor Green

Write-Host "=== End Deploy Frontend ===" -ForegroundColor Green
