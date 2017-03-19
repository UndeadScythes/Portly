@ECHO OFF
CLS
ECHO Running test suite
ECHO ================================================================================
FOR /F %%f IN ('DIR /B http\*.py') DO ..\libraries\python\python http\%%f 2>&1
ECHO ================================================================================
SET /P dummy="Test suite complete"
EXIT /B