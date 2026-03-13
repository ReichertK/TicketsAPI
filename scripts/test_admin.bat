@echo off
REM Script de pruebas para TicketsAPI
cd /d "c:\Users\Admin\Documents\GitHub\TicketsAPI"

REM Iniciar API en background
start "" cmd /c "cd TicketsAPI && dotnet bin\Release\net6.0\TicketsAPI.dll"

REM Esperar a que inicie
timeout /t 15 /nobreak

REM Ejecutar pruebas
powershell -ExecutionPolicy Bypass -File test_simple.ps1

pause
