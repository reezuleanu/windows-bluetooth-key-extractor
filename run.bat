@echo off
setlocal
set "BASEDIR=%~dp0"
if "%BASEDIR:~-1%"=="\" set "BASEDIR=%BASEDIR:~0,-1%"

set "PSEXEC=%BASEDIR%\PSTools\psexec.exe"
set "PS1PATH=%BASEDIR%\bluetooth.ps1"

REM Change dir to one folder UP, so PS script's one folder up output lands in %BASEDIR%
pushd "%BASEDIR%\.."

"%PSEXEC%" -i -s powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%PS1PATH%"

popd
pause