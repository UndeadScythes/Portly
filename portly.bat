@ECHO OFF
CLS

REM Turn echo off, clear the screen and print the script version.
SET portly_startup_version=1.0
ECHO Running Portly startup script v%portly_startup_version%

REM If the script is run as adminstrator it will have a different root directory.
REM Change directory to the location of the script.
CD %~dp0

REM Set the Portly root and config file locations.
SET portly_root=%CD%
SET config_file=%CD%\portly_config.yaml

REM Move into the source directory.
CD src

REM Start the server loop.
:server_loop

    REM Get the start time of the server.
    SET now=%TIME%
    SET /A start_time="(((1%now:~0,2%-100)*60+(1%now:~3,2%-100))*60+(1%now:~6,2%-100))*1000+(1%now:~9,2%-100)*10"

    REM Fire up the Portly WebServer.
    ECHO ======================================================================
    ECHO Starting Portly WebServer
    ruby portly.rb -d -r %portly_root% -c %config_file% 2>&1
        
    REM Get the end time.
    SET now=%TIME%
    SET /A end_time="(((1%now:~0,2%-100)*60+(1%now:~3,2%-100))*60+(1%now:~6,2%-100))*1000+(1%now:~9,2%-100)*10"
    
    REM Check how long the server was up for.
    SET /A uptime=%end_time%-%start_time%
    ECHO Server uptime: %uptime%ms
    
    REM If this value falls below the threshold then alert and wait.
    IF %uptime% LEQ 500 SET /P dummy="Startup fail detected, pausing server loop"

REM Loop!    
GOTO server_loop

REM Close the script.
SET /P dummy="Server loop terminated"
EXIT /B