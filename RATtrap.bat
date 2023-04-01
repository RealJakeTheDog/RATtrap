@echo off
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
set RAT=RATS.txt
set RN=0
echo "AntiRAT Results" > C:\log.txt

echo "Running scan, this may take some time..."

for /f "delims=," %%a in (%RAT%) DO (
    start scan.bat %%~a
    set RN +=1
)

pause 

:FoundFiles
echo "Found %~1" >> C:\log.txt
echo "Found %~1"
set RATEx=1
exit /B     

:CompleteCheck
if RATEx==1 (
    echo "RATtrap found Remote Access Tools and deleted them. Check C:\log.txt\ for more info."
) else (
    echo "No Remote Access Tools were found. Exiting now"
    timeout 10
    exit 0 
)

exit 0