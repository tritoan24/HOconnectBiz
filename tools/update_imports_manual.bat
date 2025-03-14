@echo off
echo Bắt đầu tìm kiếm và thay đổi các đường dẫn import...

cd ..
for /R lib %%f in (*.dart) do (
    echo Đang kiểm tra file: %%f
    findstr /C:"package:doanhnghiepaap/" "%%f" > nul
    if not errorlevel 1 (
        echo Đang cập nhật: %%f
        powershell -Command "(Get-Content '%%f') -replace 'package:doanhnghiepaap/', 'package:clbdoanhnhansg/' | Set-Content '%%f'"
    )
)

echo.
echo Đã hoàn thành!
pause 