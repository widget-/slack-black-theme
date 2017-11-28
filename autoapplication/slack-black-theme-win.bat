@echo OFF
REM Automatic Slack-Black-Theme Applicator
REM for Slack 2.9.0 and Slack 3.0.0 beta on Windows
REM ::::::::::::::::::::OPTIONS:::::::::::::::::::::
SET "themeCSS='https://cdn.rawgit.com/laCour/slack-night-mode/master/css/raw/black.css'"
REM Or, go with original: https://cdn.rawgit.com/widget-/slack-black-theme/master/custom.css
SET "oldPatchLocation=index.js"
SET "newPatchLocation=ssb-interop.js"
REM :::::::::::::::::::::::::::::::::::::::::::::::::
title Slack-Black-Theme-Addon
echo Set objArgs = WScript.Arguments > MessageBox.vbs
echo messageText = objArgs(0) >> MessageBox.vbs
echo MsgBox messageText >> MessageBox.vbs
FOR /F "delims=" %%X IN ('cd') DO SET origin=%%X
FOR /F "delims=" %%I IN ('dir /on /ad /b /t:c %homedrive%%homepath%\AppData\Local\slack\app-*') DO SET a=%%I
echo Applying addon to Latest Update: %a%
if not %a:app-2=% == %a% (SET writeToFile=%oldPatchLocation% & SET newVersionFlag=0) ELSE (SET writeToFile=%newPatchLocation% & SET newVersionFlag=1)
findstr /i /c:"Slack-Black-Theme-Addon" %homedrive%%homepath%\AppData\Local\slack\%a%\resources\app.asar.unpacked\src\static\%writeToFile% >nul || goto AppendSlackBlackTheme
start %origin%\MessageBox.vbs "Looks like Slack-Black-Theme is already a part of your Slack Desktop"
goto Cleanup
:AppendSlackBlackTheme
%homedrive%
cd %homedrive%%homepath%\AppData\Local\slack\%a%\resources\app.asar.unpacked\src\static\
if %newVersionFlag% == 1 (goto NewVersionPatch) ELSE (goto OldVersionPatch)
:NewVersionPatch
echo[ >> %writeToFile% & echo[ >> %writeToFile%
echo // Slack-Black-Theme-Addon >> %writeToFile%
echo document.addEventListener('DOMContentLoaded', function() { >> %writeToFile%
echo 	$.ajax({ >> %writeToFile%
echo 		url: %themeCSS%, >> %writeToFile%
echo 		success: function(css) { >> %writeToFile%
echo 		$("<style></style>").appendTo('head').html(css); >> %writeToFile%
echo 		} >> %writeToFile%
echo 	}); >> %writeToFile%
echo }); >> %writeToFile%
echo // End Slack-Black-Theme-Addon >> %writeToFile%
goto ResumeAfterPatch
:OldVersionPatch
echo[ >> %writeToFile% & echo[ >> %writeToFile%
echo // Slack-Black-Theme-Addon >> %writeToFile%
echo // First make sure the wrapper app is loaded >> %writeToFile%
echo document.addEventListener("DOMContentLoaded", function() { >> %writeToFile%
echo[ >> %writeToFile%
echo   // Then get its webviews >> %writeToFile%
echo   let webviews = document.querySelectorAll(".TeamView webview"); >> %writeToFile%
echo[ >> %writeToFile%
echo   // Fetch our CSS in parallel ahead of time >> %writeToFile%
echo   const cssPath = %themeCSS%; >> %writeToFile%
echo   let cssPromise = fetch(cssPath).then(response =^> response.text()); >> %writeToFile%
echo[ >> %writeToFile%
echo   let customCustomCSS = ` >> %writeToFile%
echo   :root { >> %writeToFile%
echo      /* Modify these to change your theme colors: */ >> %writeToFile%
echo      --primary: #09F; >> %writeToFile%
echo      --text: #CCC; >> %writeToFile%
echo      --background: #080808; >> %writeToFile%
echo      --background-elevated: #222; >> %writeToFile%
echo   } >> %writeToFile%
echo   ` >> %writeToFile%
echo[ >> %writeToFile%
echo   // Insert a style tag into the wrapper view >> %writeToFile%
echo   cssPromise.then(css =^> { >> %writeToFile%
echo      let s = document.createElement('style'); >> %writeToFile%
echo      s.type = 'text/css'; >> %writeToFile%
echo      s.innerHTML = css + customCustomCSS; >> %writeToFile%
echo      document.head.appendChild(s); >> %writeToFile%
echo   }); >> %writeToFile%
echo[ >> %writeToFile%
echo   // Wait for each webview to load >> %writeToFile%
echo   webviews.forEach(webview =^> { >> %writeToFile%
echo      webview.addEventListener('ipc-message', message =^> { >> %writeToFile%
echo         if (message.channel == 'didFinishLoading') >> %writeToFile%
echo            // Finally add the CSS into the webview >> %writeToFile%
echo            cssPromise.then(css =^> { >> %writeToFile%
echo               let script = ` >> %writeToFile%
echo                     let s = document.createElement('style'); >> %writeToFile%
echo                     s.type = 'text/css'; >> %writeToFile%
echo                     s.id = 'slack-custom-css'; >> %writeToFile%
echo                     s.innerHTML = \`${css + customCustomCSS}\`; >> %writeToFile%
echo                     document.head.appendChild(s); >> %writeToFile%
echo                     ` >> %writeToFile%
echo               webview.executeJavaScript(script); >> %writeToFile%
echo            }) >> %writeToFile%
echo      }); >> %writeToFile%
echo   }); >> %writeToFile%
echo }); >> %writeToFile%
echo // End Slack-Black-Theme-Addon >> %writeToFile%
:ResumeAfterPatch
findstr /i /c:"Slack-Black-Theme-Addon" %homedrive%%homepath%\AppData\Local\slack\%a%\resources\app.asar.unpacked\src\static\%writeToFile% >nul || goto ErrorHandler
start %origin%\MessageBox.vbs "Slack-Black-Theme has been added to your Slack Desktop"
goto Cleanup
:ErrorHandler
start %origin%\MessageBox.vbs "Slack-Black-Theme could not be added to the destination. Try running the script as an administrator"
:Cleanup
ping -n 2 127.0.0.1 > nul
del %origin%\MessageBox.vbs
exit