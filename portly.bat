@ECHO OFF

CD %~dp0

SET portly_root=%CD%
SET config_file=%CD%\portly_config.yaml

CD src

:server_loop
    ruby -d portly.rb -r %portly_root% -c %config_file% 2>&1
GOTO server_loop

SET /P dummy="Server loop terminated"
EXIT /B