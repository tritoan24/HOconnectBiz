Write-Host "Bắt đầu cập nhật các đường dẫn import..." -ForegroundColor Green

$libPath = Join-Path $PSScriptRoot "..\lib"
$changedFiles = 0
$totalFiles = 0

# Tìm tất cả file Dart trong thư mục lib
$dartFiles = Get-ChildItem -Path $libPath -Filter "*.dart" -Recurse

foreach ($file in $dartFiles) {
    $totalFiles++
    $content = Get-Content -Path $file.FullName -Raw
    
    # Thay thế import với dấu nháy đơn
    $newContent = $content -replace "import 'package:doanhnghiepaap/", "import 'package:clbdoanhnhansg/"
    
    # Thay thế import với dấu nháy kép
    $newContent = $newContent -replace 'import "package:doanhnghiepaap/', 'import "package:clbdoanhnhansg/'
    
    if ($content -ne $newContent) {
        Set-Content -Path $file.FullName -Value $newContent
        $changedFiles++
        $relativePath = $file.FullName.Replace((Get-Location).Path + "\", "")
        Write-Host "Đã cập nhật: $relativePath" -ForegroundColor Yellow
    }
}

Write-Host "`nĐã hoàn thành! Tổng số file được thay đổi: $changedFiles/$totalFiles" -ForegroundColor Green

Read-Host "Nhấn Enter để kết thúc..." 