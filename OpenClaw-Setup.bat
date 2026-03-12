@echo off
chcp 65001 >nul
title OpenClaw 安装程序
echo.
echo ========================================
echo   OpenClaw 安装程序
echo ========================================
echo.
echo 正在准备安装环境...
echo.

:: 检查是否有 powershell
where powershell >nul 2>&1
if %errorlevel% neq 0 (
    echo 错误: 未找到 PowerShell
    pause
    exit /b 1
)

:: 检查 PowerShell 版本
for /f "tokens=*" %%i in ('powershell -command "$PSVersionTable.PSVersion.Major"') do set PSVERSION=%%i
if %PSVERSION% LSS 5 (
    echo 错误: PowerShell 版本过低，需要 5.1+
    pause
    exit /b 1
)

echo PowerShell 版本: %PSVERSION%
echo.

:: 获取脚本所在目录
set "SCRIPT_DIR=%~dp0"
cd /d "%SCRIPT_DIR%"

:: 运行安装脚本
echo 开始安装...
echo.
powershell -ExecutionPolicy Bypass -NoProfile -File "%SCRIPT_DIR%install-windows.ps1"

echo.
echo ========================================
echo 安装程序已结束
echo ========================================
pause
