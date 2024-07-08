@echo off
:again
if "%~1" == "" goto done

ffmpeg -i "%~1" -b:a 160k "%~dpn1-%~x1.ogg"

shift
goto again

:done
exit