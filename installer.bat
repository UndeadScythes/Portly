@ECHO OFF

REM Check for administrator privelages.
net session >nul 2>&1
IF NOT %errorLevel% == 0 (
    SET /P dummy="Please run this script as administrator"
    EXIT /B
)

REM Clear the screen and write a placeholder for the PowerShell output.
CLS
ECHO ================================================================================
ECHO PowerShell output shows here:
ECHO.
ECHO.
ECHO.
ECHO.
ECHO ================================================================================

REM Print the script version.
SET version=1.0
ECHO Running MS Installer Script v%version%

REM Set the software versions that we will install.
SET target_ruby_version=2.3.3
SET target_git_version=2.12.0
SET target_python_version=3.6.0

REM Get the current path and set it as the Portly root path.
CD %~dp0
SET portly_root_directory=%CD%

REM Create the installer and log directories.
SET installer_directory=%portly_root_directory%\installers
IF NOT EXIST %installer_directory% MKDIR %installer_directory%
SET log_file_directory=%portly_root_directory%\logs
IF EXIST %log_file_directory% DEL %log_file_directory%\*.log
IF NOT EXIST %log_file_directory% MKDIR %log_file_directory%

REM Create the download script.
SET download_script_name=download_file.ps1
IF EXIST %download_script_name% DEL %download_script_name%
ECHO $source_url = $args[0]>>%download_script_name%
ECHO $destination_directory = $args[1]>>%download_script_name%
ECHO Invoke-WebRequest -Uri $source_url -OutFile $destination_directory>>%download_script_name%

REM The order of these installers is entirely arbitrary and is based only on the debugging performed whilst writing the script.

REM ---------------
REM Install Python.
REM ---------------
SET python_installer_name=python_installer
SET python_installer_url=https://www.python.org/ftp/python/%target_python_version%/python-%target_python_version%.exe
SET python_installer_path=%installer_directory%\%python_installer_name%.exe
SET python_directory=%portly_root_directory%\libraries\python

ECHO --------------------------------------------------------------------------------
ECHO Removing any previous copies of Python
SET python_uninstaller_path=%python_directory%\%python_installer_name%.exe
IF EXIST %python_uninstaller_path% START /WAIT %python_uninstaller_path% /passive /uninstall
DEL "%UserProfile%\AppData\local\temp\Python %target_python_version%*.log"
IF EXIST %python_directory% RMDIR /S /Q %python_directory%

ECHO Downloading Python installer v%target_python_version%
PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %python_installer_url% %python_installer_path%
ECHO Installing Python v%target_python_version%
START /WAIT %python_installer_path% /passive TargetDir=%python_directory% Shortcuts=0 Include_doc=0 Include_launcher=0 Include_pip=0 Include_tcltk=0 Include_test=0 Include_tools=0
ECHO Python installation complete

REM Python uses the installer for uninstalling so we will copy it over to the Python directory.
COPY %python_installer_path% %python_directory%\%python_installer_name%.exe>NUL

REM Move the install log to the logs folder.
MOVE "%UserProfile%\AppData\local\temp\Python %target_python_version%*.log" %log_file_directory%>NUL
DEL %log_file_directory%\*JustForMe.log
MOVE "%log_file_directory%\Python %target_python_version%*.log" %log_file_directory%\%python_installer_name%.log>NUL

SET python_test_name=python_test.py
ECHO import sys>>%python_test_name%
ECHO print(sys.version)>>%python_test_name%
FOR /F %%i IN ('%python_directory%\python %python_test_name%') DO SET python_test_output=%%i
IF EXIST %python_test_name% DEL %python_test_name%
IF NOT "%python_test_output%" == "%target_python_version%" (
    ECHO Python installation failed - %python_test_ouput%
    FIND /N /I "error" %log_file_directory%\%python_installer_name%.log
    GOTO remove_download_script
) ELSE ECHO Python installation OK

REM ------------
REM Install Git.
REM ------------
SET git_installer_name=git_installer
SET git_installer_url=https://github.com/git-for-windows/git/releases/download/v%target_git_version%.windows.1/Git-%target_git_version%-64-bit.exe
SET git_installer_path=%installer_directory%\%git_installer_name%.exe
SET git_directory=%portly_root_directory%\libraries\git

IF EXIST %git_installer_path% DEL %git_installer_path%

ECHO --------------------------------------------------------------------------------
ECHO Removing any previous copies of Git
SET git_uninstaller_path=%git_directory%\unins000.exe
IF EXIST %git_uninstaller_path% START /WAIT %git_uninstaller_path% /silent
IF EXIST %git_directory% RMDIR /S /Q %git_directory%

ECHO Downloading Git installer v%target_git_version%
PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %git_installer_url% %git_installer_path%
ECHO Installing Git v%target_git_version%
START /WAIT %git_installer_path% /SILENT /DIR="%git_directory%" /LOG="%log_file_directory%\%git_installer_name%.log"
ECHO Git installation complete

SET "full_git_version=git version %target_git_version%.windows.1"
FOR /F "DELIMS=" %%i IN ('%git_directory%\bin\git --version') DO SET git_test_output=%%i
IF NOT "%git_test_output%" == "%full_git_version%" (
    ECHO Git installation failed - %git_test_output%
    FIND /N /I "error" %log_file_directory%\%git_installer_name%.log
    GOTO remove_download_script
) ELSE (
    ECHO Git installation OK
)

REM -------------
REM Install Ruby.
REM -------------
SET ruby_installer_name=ruby_installer
SET ruby_installer_url=https://dl.bintray.com/oneclick/rubyinstaller/rubyinstaller-%target_ruby_version%-x64.exe
SET ruby_installer_path=%installer_directory%\%ruby_installer_name%.exe
SET ruby_directory=%portly_root_directory%\libraries\ruby

IF EXIST %ruby_installer_path% DEL %ruby_installer_path%

ECHO --------------------------------------------------------------------------------
ECHO Removing any previous copies of Ruby
SET ruby_uninstaller_path=%ruby_directory%\unins000.exe
IF EXIST %ruby_uninstaller_path% START /WAIT %ruby_uninstaller_path% /silent
IF EXIST %ruby_directory% RMDIR /S /Q %ruby_directory%

ECHO Downloading Ruby installer v%target_ruby_version%
PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %ruby_installer_url% %ruby_installer_path%
ECHO Installing Ruby v%target_ruby_version%
START /WAIT %ruby_installer_path% /SILENT /DIR="%ruby_directory%" /TASKS="modpath" /LOG="%log_file_directory%\%ruby_installer_name%.log"
ECHO Ruby installation complete

SET ruby_test_name=ruby_test.rb
ECHO puts("#{RUBY_VERSION}")>>%ruby_test_name%
FOR /F %%i IN ('%ruby_directory%\bin\ruby %ruby_test_name%') DO SET ruby_test_output=%%i
IF EXIST %ruby_test_name% DEL %ruby_test_name%
IF NOT "%ruby_test_output%" == "%target_ruby_version%" (
    ECHO Ruby installation failed - %ruby_test_output%
    FIND /N /I "error" %log_file_directory%\%ruby_installer_name%.log
    GOTO remove_download_script
) ELSE (
    ECHO Ruby installation OK
)

REM -----------------------------
REM Clone the project repository.
REM -----------------------------
set git_executable=%git_directory%\bin\git

ECHO -----------------------------------------
ECHO Fetching repository code base from GitHub
%git_executable% init
%git_executable% remote add origin https://github.com/UndeadScythes/Portly.git
%git_executable% fetch
%git_executable% checkout -t origin/master

:remove_download_script
REM Remove the download script and installers.
DEL %download_script_name%
RMDIR /S /Q %installer_directory%

SET /P dummy="Script complete"