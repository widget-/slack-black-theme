# Windows 10 Automation

## Add this script 
`cd %LOCALAPPDATA%\slack`

create your file here...

slack-black-theme.bat
```batch
@echo OFF
REM Automatic Slack-Black-Theme Applicator
REM ::::::::::::::::::::OPTIONS:::::::::::::::::::::
SET "themeJS='https://cdn.rawgit.com/Artistan/slack-black-theme/master/addEventListener.js'"
REM :::::::::::::::::::::::::::::::::::::::::::::::::
title Slack-Black-Theme-Addon
echo Set objArgs = WScript.Arguments > MessageBox.vbs
echo messageText = objArgs(0) >> MessageBox.vbs
echo MsgBox messageText >> MessageBox.vbs
cd %LOCALAPPDATA%\slack
Taskkill /F /IM slack.exe
TIMEOUT /t 5 /nobreak
start /wait slack.exe
TIMEOUT /t 15 /nobreak
FOR /F "delims=" %%X IN ('cd') DO SET origin=%%X
FOR /F "delims=" %%I IN ('dir /on /ad /b /t:c %LOCALAPPDATA%\slack\app-*') DO SET a=%%I
echo Applying addon to Latest Update: %a%
findstr /i /c:"Slack-Black-Theme-Addon" %LOCALAPPDATA%\slack\%a%\resources\app.asar.unpacked\src\static\index.js >nul || goto AppendSlackBlackTheme
start %origin%\MessageBox.vbs "Looks like Slack-Black-Theme is already a part of your Slack Desktop"
goto Cleanup
:AppendSlackBlackTheme
cd %LOCALAPPDATA%\slack\%a%\resources\app.asar.unpacked\src\static\
:DownloadJS
powershell -Command "(New-Object Net.WebClient).DownloadFile( %themeJS%, 'addEventListener.js')"
echo.>>addEventListener-new.js
echo // Slack-Black-Theme-Addon>>addEventListener-new.js
echo.>>addEventListener-new.js
type addEventListener.js>>addEventListener-new.js
del addEventListener.js
ren addEventListener-new.js addEventListener.js
:CustomizeStyleHere
:AppendFile
type addEventListener.js >> index.js
type addEventListener.js >> ssb-interop.js
del addEventListener.js
cd ../../../../..
: restart slack since it was updated
Taskkill /F /IM slack.exe
:ResumeAfterPatch
findstr /i /c:"Slack-Black-Theme-Addon" %LOCALAPPDATA%\slack\%a%\resources\app.asar.unpacked\src\static\index.js >nul || goto ErrorHandler
start %origin%\MessageBox.vbs "Slack-Black-Theme has been added to your Slack Desktop"
goto Cleanup
:ErrorHandler
start %origin%\MessageBox.vbs "Slack-Black-Theme could not be added to the destination. Try running the script as an administrator"
:Cleanup
ping -n 2 127.0.0.1 > nul
del %origin%\MessageBox.vbs
start /wait slack.exe
```

### optional colors

`:CustomizeStyleHere` -- look for this line and add it there.

```batch
: This is an example of the One Dark theme automated also.
powershell "(gc addEventListener.js) -replace 'primary: .*;', 'primary: #61AFEF;' | out-file addEventListener.js"
powershell "(gc addEventListener.js) -replace 'text: .*;', 'text: #ABB2BF;' | out-file addEventListener.js"
powershell "(gc addEventListener.js) -replace 'background: .*;', 'background: #282C34;' | out-file addEventListener.js"
powershell "(gc addEventListener.js) -replace 'background-elevated: .*;', 'background-elevatedy: #3B4048;' | out-file addEventListener.js"
```

## shortcut - minimized

change Icon to slack icon ... "%LOCALAPPDATA%\slack"

![Icon](https://user-images.githubusercontent.com/801349/34311448-4b032e76-e723-11e7-919a-7146121a1222.png)

## run as administrator

![administrator](https://user-images.githubusercontent.com/801349/34311438-43a859bc-e723-11e7-9a9d-010c82965a8f.png)
