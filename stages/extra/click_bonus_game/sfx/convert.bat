@echo off
:again
if "%~1" == "" goto done

ffmpeg -i "%~1" "%~dpn1-.wav"

shift
goto again

:done
exit