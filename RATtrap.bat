@echo off
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
set RAT=RATS.txt
set RN=0
echo "AntiRAT Results" > C:\log.txt
echo "Please input the folder or drive you want to scan (leave blank for full system scan):"
set /p CurrentDir=
if "%CurrentDir%"=="" set CurrentDir=C:\
echo "Running scan, this may take some time..."

for /f "delims=," %%a in (%RAT%) DO (
    call :Scan %%~a
    set /a RN+=1
    set /a Progress=RN*100/50
    echo Progress: %Progress%%%... 
)

pause 
goto :eof

:FoundFiles
echo %date% %time% - Found %~1 - Action: Deleted - Status: Success >> C:\log.txt
echo "Found %~1"
set RATEx=1
exit /B     

:CompleteCheck
if RATEx==1 (
    echo "RATtrap found Remote Access Tools and deleted them. Check C:\log.txt for more info."
) else (
    echo "No Remote Access Tools were found. Exiting now"
    timeout 10
    exit 0 
)

exit 0

:Scan
set "params=%*"
echo "Scanning %~1"
for /R "%CurrentDir%" %%a in ("%~1"*) DO (
    echo "%%~nxa"
    IF EXIST "%%~fa" (
        call :FoundFiles "%%~fa"
        taskkill /f /im %~1*
        del /s /q %%~fa
        rmdir /s /q %%~fa
    )
)
call :CompleteCheck
EXIT 0
