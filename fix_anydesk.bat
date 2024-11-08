@echo off
:: Request administrative privileges
:: Using PowerShell to restart with elevated privileges if necessary
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -Command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Brief description for the user
cls
echo This script will do the following:
echo 1. Delete AnyDesk data.
echo 2. Uninstall AnyDesk. 
echo 3. Download and install AnyDesk again.
echo ALL ANYDESK DATA WILL BE LOST (recent computers, passwords, etc.). YOUR ID WILL CHANGE.
echo Press any key to continue or Ctrl+C to cancel.
pause >nul

:: Stop the AnyDesk service
sc stop "AnyDesk" >nul 2>&1

:: Kill AnyDesk tasks
taskkill /f /im "AnyDesk.exe" /t >nul 2>&1

:: Delete AnyDesk files in %AppData%
set anydesk_folder=%AppData%\AnyDesk
if exist "%anydesk_folder%" (
    rmdir /s /q "%anydesk_folder%"
)

:: Start the AnyDesk uninstaller
set anydesk_uninstall_path=C:\Program Files (x86)\AnyDesk\AnyDesk.exe
if exist "%anydesk_uninstall_path%" (
    echo Starting AnyDesk uninstallation...
    start /wait "" "%anydesk_uninstall_path%" --remove
)

:: Notify user that AnyDesk will be downloaded
echo Downloading and installing AnyDesk...

:: Download and install AnyDesk
set anydesk_download_url=https://download.anydesk.com/AnyDesk.exe
set anydesk_installer=%temp%\AnyDesk.exe
curl -L -o %anydesk_installer% %anydesk_download_url%

:: Run the installer
if exist %anydesk_installer% (
    start /wait "" %anydesk_installer% --install "C:\Program Files (x86)\AnyDesk" --start-with-win --create-shortcuts --create-desktop-icon
) else (
    echo Failed to download AnyDesk.
    pause
)

:: Notify completion
echo AnyDesk installation complete.