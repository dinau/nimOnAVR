@echo off
REM For AVR UNO : atmega328p, 16MHz

set COM=COM3
set DUDE_DIR="D:\arduino-1.8.16\hardware\tools\avr"
set BUIL_DIR=".BUILD"
set hex=%BUIL_DIR%/"main.elf"
set AVRDUDE="%DUDE_DIR%\bin\avrdude.exe"
set CONF="%DUDE_DIR%\etc\avrdude.conf"

@echo on
%AVRDUDE% -c arduino -P %COM% -C %CONF% -p m328p -b 115200  -u -e -U flash:w:%hex%:a
