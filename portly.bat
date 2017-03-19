@ECHO OFF

CD %~dp0
CD src

:server_loop
    ruby -d portly.rb 2>&1
GOTO server_loop

SET /P dummy="Server loop terminated"
EXIT /B