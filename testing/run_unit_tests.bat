@ECHO OFF

REM Turn echo off and clear the screen.
CLS

REM Start the test suite.
ECHO Running test suite
ECHO ================================================================================

REM Run each Python script in the "portly" directory.
FOR /F %%f IN ('DIR /B portly\*.py') DO ..\libraries\python\python portly\%%f 2>&1

REM Run each Ruby script in the "crypto" directory.
FOR /F %%f IN ('DIR /B crypto\*.rb') DO ..\libraries\ruby\bin\ruby crypto\%%f 2>&1

REM End the test suite.
ECHO ================================================================================
SET /P dummy="Test suite complete"

REM End the batch file.
EXIT /B