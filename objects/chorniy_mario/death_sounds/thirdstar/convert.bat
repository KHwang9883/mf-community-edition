@echo off
:again
if "%~1" == "" goto done

ffmpeg -i "%~1" "%~dpn1%~x1.ogg"

shift
goto again

:done
exit