@echo off
SETLOCAL

set "found=0"

for /r C:\ %%f in (Fasenium_source.py) do (
    set "found=1"
    set "script_path=%%f"
    goto :found
)

:found
if %found%==1 (
    echo Running script: %script_path%
    python "%script_path%"
    IF ERRORLEVEL 1 (
        echo Error encountered while running %script_path%.
        pause
        exit /b 1
    )
) else (
    echo Fasenium_source.py not found on this computer.
    pause
    exit /b 1
)

pause
