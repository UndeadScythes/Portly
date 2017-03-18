@ECHO OFF

CD src

:server_loop
    ruby -d portly.rb
GOTO server_loop

SET /P dummy="Server loop terminated"