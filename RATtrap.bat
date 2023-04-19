@echo off
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
if not exist "RATS.txt" (
    echo "RATS.txt not found. Exiting..."
    exit 1
)
if not exist "Signatures.txt" (
    echo "Signatures.txt not found. Exiting..."
    exit 1
)
set RAT=RATS.txt
set /a RN=0
set /a TotalRATs=0
for /f %%a in ('type "RATS.txt" ^| find /v /c ""') do set /a TotalRATs=%%a
echo "AntiRAT Results" > C:\log.txt
echo "Please input the folder or drive you want to scan (leave blank for full system scan):"
set /p CurrentDir=
if "%CurrentDir%"=="" set CurrentDir=C:\
if not exist "%CurrentDir%" (
    echo "Invalid directory. Exiting..."
    exit 1
)
echo "Running scan, this may take some time..."

for /f "delims=," %%a in (%RAT%) DO (
    call :Scan %%~a
    set /a RN+=1
    set /a Progress=RN*100/TotalRATs
    echo Progress: %Progress%%%... 
)

call :AdvancedScan
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

:AdvancedScan
echo "Running advanced scan..."
for /R "%CurrentDir%" %%a in ("*.exe" "*.dll" "*.bat" "*.vbs" "*.ps1") DO (
    call :HeuristicCheck "%%~fa"
)
goto :eof

:HeuristicCheck
set "file=%~1"
for /f "tokens=2 delims=: " %%a in ('findstr /m /l /g:"Signatures.txt" "%file%"') do (
    echo "Possible RAT detected: %file% (Signature: %%a)"
    echo %date% %time% - Found %file% - Action: Analyzed - Status: Possible RAT (Signature: %%a) >> C:\log.txt
)
exit /B
