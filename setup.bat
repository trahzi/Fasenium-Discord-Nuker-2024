@echo off
SETLOCAL

set /p "directory=Enter the directory where fanium.py is located (e.g., C:\Users\yesmr\Downloads): "
set /p "script=Enter the name of the Python script (e.g., fanium.py): "

cd /d "%directory%"

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

python "%script%"
IF ERRORLEVEL 1 (
    echo Error encountered while running %script%.
    pause
    exit /b 1
)

pause
