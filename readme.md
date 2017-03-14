# Slack Black Theme

A darker, more contrasty, Slack theme.

# Preview

TODO: Join a Slack team that I can screenshot.

# Installing into Slack

Find your Slack's application directory.

* Windows: `%homepath%\AppData\Local\slack\`
* Mac: `/Applications/Slack.app/Contents/`
* Linux: `???`


Open up the most recent version (e.g. `app-2.5.1`) then open
`resources\app.asar.unpacked\src\static\index.js`

At the bottom, just before the final `});`, add

```js
// First make sure the wrapper app is loaded
document.addEventListener("DOMContentLoaded", function() {
   // Then get its webviews
   let webviews = document.querySelectorAll(".TeamView webview");

   // Fetch our CSS in parallel ahead of time
   const cssPath = 'https://cdn.rawgit.com/widget-/slack-black-theme/master/custom.css'
   let cssPromise = fetch(cssPath).then(response => response.text());

   // Insert a style tag into the wrapper view
   cssPromise.then(css => {
      let s = document.createElement('style');
      s.type = 'text/css';
      s.innerHTML = css;
      document.head.appendChild(s);
   });

   // Wait for each webview to load
   webviews.forEach(webview => {
      webview.addEventListener('ipc-message', message => {
         if (message.channel == 'didFinishLoading')
            // Finally add the CSS into the webview
            cssPromise.then(css => webview.insertCSS(css))
      });
   });
```

(Note that you can put _any_ CSS there.)

That's it! Restart Slack and see how well it works.

NB: You'll have to do this every time Slack updates.

# License

Apache 2.0
