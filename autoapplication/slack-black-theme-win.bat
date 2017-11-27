@echo off
title Slack-Black-Theme-Addon
echo Set objArgs = WScript.Arguments > MessageBox.vbs
echo messageText = objArgs(0) >> MessageBox.vbs
echo MsgBox messageText >> MessageBox.vbs
FOR /F "delims=" %%x IN ('cd') DO SET origin=%%x
FOR /F "delims=" %%i IN ('dir /on /ad /b /t:c %homedrive%%homepath%\AppData\Local\slack\app-*') DO SET a=%%i
echo Applying addon to Latest Update: %a%
findstr /i /c:"Slack-Black-Theme-Addon" %homedrive%%homepath%\AppData\Local\slack\%a%\resources\app.asar.unpacked\src\static\index.js >nul || goto AppendSlackBlackTheme
start %origin%\MessageBox.vbs "Looks like Slack-Black-Theme is already a part of your Slack Desktop"
goto Cleanup
:AppendSlackBlackTheme
%homedrive%
cd %homedrive%%homepath%\AppData\Local\slack\%a%\resources\app.asar.unpacked\src\static\
echo[ >> index.js
echo[ >> index.js
echo // Slack-Black-Theme-Addon >> index.js
echo // First make sure the wrapper app is loaded >> index.js
echo document.addEventListener("DOMContentLoaded", function() { >> index.js
echo[ >> index.js
echo   // Then get its webviews >> index.js
echo   let webviews = document.querySelectorAll(".TeamView webview"); >> index.js
echo[ >> index.js
echo   // Fetch our CSS in parallel ahead of time >> index.js
echo   const cssPath = 'https://cdn.rawgit.com/widget-/slack-black-theme/master/custom.css'; >> index.js
echo   let cssPromise = fetch(cssPath).then(response =^> response.text()); >> index.js
echo[ >> index.js
echo   let customCustomCSS = ` >> index.js
echo   :root { >> index.js
echo      /* Modify these to change your theme colors: */ >> index.js
echo      --primary: #09F; >> index.js
echo      --text: #CCC; >> index.js
echo      --background: #080808; >> index.js
echo      --background-elevated: #222; >> index.js
echo   } >> index.js
echo   ` >> index.js
echo[ >> index.js
echo   // Insert a style tag into the wrapper view >> index.js
echo   cssPromise.then(css =^> { >> index.js
echo      let s = document.createElement('style'); >> index.js
echo      s.type = 'text/css'; >> index.js
echo      s.innerHTML = css + customCustomCSS; >> index.js
echo      document.head.appendChild(s); >> index.js
echo   }); >> index.js
echo[ >> index.js
echo   // Wait for each webview to load >> index.js
echo   webviews.forEach(webview =^> { >> index.js
echo      webview.addEventListener('ipc-message', message =^> { >> index.js
echo         if (message.channel == 'didFinishLoading') >> index.js
echo            // Finally add the CSS into the webview >> index.js
echo            cssPromise.then(css =^> { >> index.js
echo               let script = ` >> index.js
echo                     let s = document.createElement('style'); >> index.js
echo                     s.type = 'text/css'; >> index.js
echo                     s.id = 'slack-custom-css'; >> index.js
echo                     s.innerHTML = \`${css + customCustomCSS}\`; >> index.js
echo                     document.head.appendChild(s); >> index.js
echo                     ` >> index.js
echo               webview.executeJavaScript(script); >> index.js
echo            }) >> index.js
echo      }); >> index.js
echo   }); >> index.js
echo }); >> index.js
echo // End Slack-Black-Theme-Addon >> index.js
echo[ >> index.js
findstr /i /c:"Slack-Black-Theme-Addon" %homedrive%%homepath%\AppData\Local\slack\%a%\resources\app.asar.unpacked\src\static\index.js >nul || goto ErrorHandler
start %origin%\MessageBox.vbs "Slack-Black-Theme has been added to your Slack Desktop"
goto Cleanup
:ErrorHandler
start %origin%\MessageBox.vbs "Slack-Black-Theme could not be added to the destination. Try running the script as an administrator"
:Cleanup
ping -n 2 127.0.0.1 > nul
del %origin%\MessageBox.vbs
exit