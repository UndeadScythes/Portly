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
ECHO Running Portly MS Installer Script v%version%

REM Set the software versions that we will install.
SET target_ruby_version=2.3.3
SET target_git_version=2.12.0
SET target_python_version=3.6.0
SET target_mariadb_version=10.1.22
SET target_apache_version=2.4.25
SET target_sevenzip_version=1604

REM Set credentials for anything that requires a username or password.
SET mariadb_root_password=portly

REM Set flags to run each part of this installer.
SET install_ruby=false
SET install_git=false
SET install_python=false
SET install_mariadb=false
SET install_apache=true
SET install_sevenzip=false
SET install_unzip=true
SET fetch_from_github=false
SET run_mariadb_setup_sql=false
SET remove_installers=false

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
REM The exception to the rule: Unzip must come before Apache.

REM --------------
REM Install Unzip.
REM --------------
IF NOT %install_unzip%==true GOTO skip_install_unzip

    SET unzip_url=http://stahlworks.com/dev/unzip.exe
    SET unzip_directory=%portly_root_directory%\libraries\unzip
    IF NOT EXIST %unzip_directory%\unzip.exe (
        PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %unzip_url% %unzip_directory%
        ECHO Unzip downloaded
    ) ELSE ECHO Unzip already exists

:skip_install_unzip

REM --------------
REM Install 7-Zip.
REM --------------
IF NOT %install_sevenzip%==true GOTO skip_install_sevenzip

    SET sevenzip_installer_name=sevenzip_installer
    SET sevenzip_installer_url=http://www.7-zip.org/a/7z%target_sevenzip_version%-x64.exe
    SET sevenzip_installer_path=%installer_directory%\%sevenzip_installer_name%.exe
    SET sevenzip_directory=%portly_root_directory%\libraries\7zip
    
    ECHO --------------------------------------------------------------------------------
    ECHO Removing any previous copies of 7-Zip
    IF EXIST %sevenzip_directory% RMDIR /S /Q %sevenzip_directory%

    ECHO Downloading 7-Zip installer v%target_sevenzip_version%
    IF NOT EXIST %sevenzip_installer_path% (
        PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %sevenzip_installer_url% %sevenzip_installer_path%
    ) ELSE ECHO Installer already exists
    ECHO Installing 7-Zip v%target_sevenzip_version%
    ECHO ========================================
    ECHO This is a manual installation.
    ECHO Please install to the following directory:
    ECHO %sevenzip_directory%
    ECHO ========================================
    SET /P dummy="Hit enter to continue..."
    %sevenzip_installer_path%
    ECHO 7-Zip installation complete

:skip_install_sevenzip

REM ---------------
REM Install Apache.
REM ---------------
IF NOT %install_apache%==true GOTO skip_install_apache

    SET apache_installer_name=apache_installer
    SET apache_installer_url=https://www.apachelounge.com/download/VC14/binaries/httpd-%target_apache_version%-win64-VC14.zip
    SET apache_installer_path=%installer_directory%\%apache_installer_name%.zip
    SET apache_directory=%portly_root_directory%\libraries\apache

    ECHO --------------------------------------------------------------------------------
    ECHO Removing any previous copies of Apache
    IF EXIST %apache_directory% RMDIR /S /Q %apache_directory%

    ECHO Downloading Apache installer v%target_apache_version%
    IF NOT EXIST %apache_installer_path% (
        PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %apache_installer_url% %apache_installer_path%
    ) ELSE ECHO Installer already exists
    
    SET unzip_exe=%portly_root_directory%\libraries\unzip\unzip.exe
    IF NOT EXIST %unzip_exe% (
        ECHO Unzip does not exists, cannot install Apache
        GOTO skip_install_apache
    )
    ECHO Installing Apache v%target_apache_version%
    %unzip_exe% -q %apache_installer_path% -d %apache_directory%
    ECHO Apache installation complete

:skip_install_apache

REM ---------------
REM Install MariaDB.
REM ---------------
IF NOT %install_mariadb%==true GOTO skip_install_mariadb

    SET mariadb_installer_name=mariadb_installer
    SET mariadb_installer_url=https://downloads.mariadb.org/f/mariadb-%target_mariadb_version%/winx64-packages/mariadb-%target_mariadb_version%-winx64.msi/from/http%%3A//mirror.sax.uk.as61049.net/mariadb/?serve
    SET mariadb_installer_path=%installer_directory%\%mariadb_installer_name%.msi
    SET mariadb_directory=%portly_root_directory%\libraries\mariadb

    ECHO --------------------------------------------------------------------------------
    ECHO Removing any previous copies of MariaDB
    SET mariadb_uninstaller_path=%mariadb_directory%\%mariadb_installer_name%.msi
    IF EXIST %mariadb_uninstaller_path% msiexec /i %mariadb_installer_path% REMOVE=ALL CLEANUPDATA=1 /qn
    IF EXIST %mariadb_directory% RMDIR /S /Q %mariadb_directory%

    ECHO Downloading MariaDB installer v%target_mariadb_version%
    IF NOT EXIST %mariadb_installer_path% (
        PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %mariadb_installer_url% %mariadb_installer_path%
    ) ELSE ECHO Installer already exists
    ECHO Installing MariaDB v%target_mariadb_version%
    msiexec /i %mariadb_installer_path% INSTALLDIR=%mariadb_directory% PASSWORD=%mariadb_root_password% SERVICENAME=MySQL UTF8=1 /qn /log %log_file_directory%\%mariadb_installer_name%.log
    ECHO MariaDB installation complete

    REM MariaDB uses the installer for uninstalling so we will copy it over to the MariaDB directory.
    COPY %mariadb_installer_path% %mariadb_directory%\%mariadb_installer_name%.msi>NUL

    SET "full_mariadb_version=%target_mariadb_version%-MariaDB"
    FOR /F "DELIMS=" %%i IN ('%mariadb_directory%\bin\mysql --user^=root --password^=%mariadb_root_password% mysql --execute^="SELECT VERSION();"') DO SET mariadb_test_output=%%i
    IF NOT "%mariadb_test_output%" == "%full_mariadb_version%" (
        ECHO MariaDB installation failed - %mariadb_test_output%
        FIND /N /I "error" %log_file_directory%\%mariadb_installer_name%.log
        GOTO remove_download_script
    ) ELSE ECHO MariaDB installation OK

:skip_install_mariadb

REM ---------------
REM Install Python.
REM ---------------
IF NOT %install_python%==true GOTO skip_install_python

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
    IF NOT EXIST %python_installer_path% (
        PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %python_installer_url% %python_installer_path%
    ) ELSE ECHO Installer already exists
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

:skip_install_python

REM ------------
REM Install Git.
REM ------------
IF NOT %install_git%==true GOTO skip_install_git

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
    IF NOT EXIST %git_installer_path% (
        PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %git_installer_url% %git_installer_path%
    ) ELSE ECHO Installer already exists
    ECHO Installing Git v%target_git_version%
    START /WAIT %git_installer_path% /SILENT /DIR="%git_directory%" /LOG="%log_file_directory%\%git_installer_name%.log"
    ECHO Git installation complete

    SET "full_git_version=git version %target_git_version%.windows.1"
    FOR /F "DELIMS=" %%i IN ('%git_directory%\bin\git --version') DO SET git_test_output=%%i
    IF NOT "%git_test_output%" == "%full_git_version%" (
        ECHO Git installation failed - %git_test_output%
        FIND /N /I "error" %log_file_directory%\%git_installer_name%.log
        GOTO remove_download_script
    ) ELSE ECHO Git installation OK

:skip_install_git

REM -------------
REM Install Ruby.
REM -------------
IF NOT %install_ruby%==true GOTO skip_install_ruby

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
    IF NOT EXIST %ruby_installer_path% (
        PowerShell.exe -ExecutionPolicy RemoteSigned -File %portly_root_directory%\download_file.ps1 %ruby_installer_url% %ruby_installer_path%
    ) ELSE ECHO Installer already exists
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
    ) ELSE ECHO Ruby installation OK

:skip_install_ruby

REM -----------------------------
REM Clone the project repository.
REM -----------------------------
IF NOT %fetch_from_github%==true GOTO skip_fetch_from_github

    SET git_executable=%git_directory%\bin\git

    ECHO -----------------------------------------
    ECHO Fetching repository code base from GitHub
    %git_executable% init
    %git_executable% remote add origin https://github.com/UndeadScythes/Portly.git
    %git_executable% fetch
    %git_executable% checkout -t origin/master

:skip_fetch_from_github

REM ---------------------------------------------    
REM Run any SQL scripts for the setup of MariaDB.
REM ---------------------------------------------
IF NOT %run_mariadb_setup_sql%==true GOTO skip_run_mariadb_setup_script

    FOR /F %%f IN ('DIR /B setup_sql\mariadb\*.sql') DO libraries\mariadb\bin\mysql --user=root --password=%mariadb_root_password% mysql < setup_sql\mariadb\%%f 2>&1
    
:skip_run_mariadb_setup_script    

REM Remove the download script and installers.
IF %remove_installers%==true RMDIR /S /Q %installer_directory%
:remove_download_script
DEL %download_script_name%

SET /P dummy="Script complete"