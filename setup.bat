@echo off
SETLOCAL

python --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo Python is not installed.
    pause
    exit /b 1
)

pip install discord.py colorama >nul 2>&1
IF ERRORLEVEL 1 (
    echo Failed to install packages.
    pause
    exit /b 1
)

echo Current directory: %CD%

python "%CD%\fanium.py"
IF ERRORLEVEL 1 (
    echo Error encountered while running fanium.py.
    pause
    exit /b 1
)

pause
