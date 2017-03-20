@ECHO OFF

REM Turn echo off and clear the screen.
CLS

REM Get the source directory.
SET testing_directory=%CD%
CD ..\src
SET src_directory=%CD%
CD %testing_directory%

REM Start the test suite.
ECHO Running test suite
ECHO ================================================================================

REM Run each Ruby script in the "crypto" directory.
ECHO Running cryptographic tests
FOR /F %%f IN ('DIR /B crypto\*.rb') DO ..\libraries\ruby\bin\ruby -I %src_directory%\crypto crypto\%%f 2>&1

REM Run each Ruby script in the "logging" directory.
ECHO Running logging tests
FOR /F %%f IN ('DIR /B logging\*.rb') DO ..\libraries\ruby\bin\ruby -I %src_directory%\logging logging\%%f 2>&1

REM Run each Python script in the "portly" directory.
ECHO Running Portly WebServer tests
FOR /F %%f IN ('DIR /B portly\*.py') DO ..\libraries\python\python portly\%%f 2>&1

REM End the test suite.
ECHO ================================================================================
SET /P dummy="Test suite complete"

REM End the batch file.
EXIT /B