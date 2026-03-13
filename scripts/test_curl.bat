@echo off
REM Pruebas de TicketsAPI usando CURL

setlocal enabledelayedexpansion

set "API=https://localhost:5001/api/v1"
set "TEMP_FILE=%TEMP%\api_response.json"

REM 1. LOGIN
echo [1/12] LOGIN...
curl -s -k -X POST "%API%/Auth/login" ^
  -H "Content-Type: application/json" ^
  -d "{\"usuario\":\"Admin\",\"contrasena\":\"changeme\"}" ^
  -o "%TEMP_FILE%"

REM Extraer token (usando findstr)
for /f "tokens=*" %%a in (%TEMP_FILE%) do (
  set "LOGIN_RESPONSE=%%a"
)

echo Response: %LOGIN_RESPONSE%

REM Si necesitas un método más simple, aquí van las pruebas basadas en CURL
echo.
echo [2/12] GET /Tickets...
curl -s -k -X GET "%API%/Tickets" -H "Content-Type: application/json" | more

echo.
echo PRUEBAS COMPLETADAS

pause
