@echo off
set CurrentDir=C:\
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )

echo "Scanning %~1"
for /R "%CurrentDir%" %%a in ("%~1"*) DO (
    echo "%%~nxa"
    IF EXIST "%%~fa" (
        call :FoundFiles RATtrap.bat "%%~fa"
        taskkill /f /im %~1*
        del /s /q %%~fa
        rmdir /s /q %%~fa
    )
)
call :CompleteCheck RATtrap.bat
EXIT 0