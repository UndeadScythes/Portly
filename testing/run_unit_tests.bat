@ECHO OFF
CLS
ECHO Running test suite
..\libraries\python\python run_unit_tests.py
SET /P dummy="Test suite complete"