# Slack Black Theme

A darker, more contrasty, Slack theme.

# Preview

![Screenshot](https://cloud.githubusercontent.com/assets/7691630/24120350/4cbb643e-0d82-11e7-8353-5d4eb65dfd6a.png)

# Installing into Slack

0. Make sure slack is not running

## Via script (automatic "installer" for version 3/4)

### On Windows
1. Make sure [7-zip](https://7-zip.de/download.html) is installed
2. Make sure the [asar-plugin for 7-zip](http://www.tc4shell.com/en/7zip/asar/) is installed
3. Execute slackBlack.ps1 (Thanks to [tarantulae](https://github.com/tarantulae) on whose script this is largely based)
### On Unix (MacOS/Linux)
1. Make sure nodejs/npm are installed (`sudo apt install nodejs npm`)
2. Make sure the asar package is installed (`sudo npm i -g npx asar`)
3. Execute darkSlack.sh (Thanks to [smitt04](https://github.com/smitt04) on whose script this is based)

## Manually
Find your Slack's application directory.

* Windows: `%homepath%\AppData\Local\slack\`
* Mac: `/Applications/Slack.app/Contents/`
* Linux: `/usr/lib/slack/` (Debian-based)

### For version 4.0.0+
3. Go to folder "resources"
4. Open app.asar with 7-zip
5. In 7-zip, view the file (with right-click on the file) to `app\dist\ssb-interop.bundle.js` and add the code below (section "Code to add").
6. Save **and close the editor**, then press "OK" on the question whether the archive is to be updated.

### For versions up to Slack 3

Add the code shown below to
`resources\app.asar.unpacked\src\static\index.js`

and to:
`resources\app.asar.unpacked\src\static\ssb-interop.js`

### Code to add 

```js
// First make sure the wrapper app is loaded
document.addEventListener("DOMContentLoaded", function() {

   // Then get its webviews
   let webviews = document.querySelectorAll(".TeamView webview");

   // Fetch our CSS in parallel ahead of time
   const cssPath = 'https://cdn.rawgit.com/widget-/slack-black-theme/master/custom.css';
   let cssPromise = fetch(cssPath).then(response => response.text());

   let customCustomCSS = `
   :root {
      /* Modify these to change your theme colors: */
      --primary: #09F;
      --text: #999;
      --background: #111;
      --background-elevated: #222;
   }
   `

   // Insert a style tag into the wrapper view
   cssPromise.then(css => {
      let s = document.createElement('style');
      s.type = 'text/css';
      s.innerHTML = css + customCustomCSS;
      document.head.appendChild(s);
   });

   // Wait for each webview to load
   webviews.forEach(webview => {
      webview.addEventListener('ipc-message', message => {
         if (message.channel == 'didFinishLoading')
            // Finally add the CSS into the webview
            cssPromise.then(css => {
               let script = `
                     let s = document.createElement('style');
                     s.type = 'text/css';
                     s.id = 'slack-custom-css';
                     s.innerHTML = \`${css + customCustomCSS}\`;
                     document.head.appendChild(s);
                     `
               webview.executeJavaScript(script);
            })
      });
   });
});
```

Notice that you can edit any of the theme colors using the custom CSS (for
the already-custom theme.) Also, you can put any CSS URL you want here,
so you don't necessarily need to create an entire fork to change some small styles.

That's it! Restart Slack and see how well it works.

NB: You'll have to do this every time Slack updates.
# Development

`git clone` the project and `cd` into it.

Change the CSS URL to `const cssPath = 'http://localhost:8080/custom.css';`

Run a static webserver of some sort on port 8080:

```bash
npm install -g static
static .
```

In addition to running the required modifications, you will likely want to add auto-reloading:

```js
const cssPath = 'http://localhost:8080/custom.css';
const localCssPath = '/Users/bryankeller/Code/slack-black-theme/custom.css';

window.reloadCss = function() {
   const webviews = document.querySelectorAll(".TeamView webview");
   fetch(cssPath + '?zz=' + Date.now(), {cache: "no-store"}) // qs hack to prevent cache
      .then(response => response.text())
      .then(css => {
         console.log(css.slice(0,50));
         webviews.forEach(webview =>
            webview.executeJavaScript(`
               (function() {
                  let styleElement = document.querySelector('style#slack-custom-css');
                  styleElement.innerHTML = \`${css}\`;
               })();
            `)
         )
      });
};

fs.watchFile(localCssPath, reloadCss);
```

Instead of launching Slack normally, you'll need to enable developer mode to be able to inspect things.

* Mac: `export SLACK_DEVELOPER_MENU=true; open -a /Applications/Slack.app`

* Linux: (todo)

* Windows: (todo)

# License

Apache 2.0

# Color Schemes

Here's some example color variations you might like.

## Default
![Default](https://cloud.githubusercontent.com/assets/7691630/24120350/4cbb643e-0d82-11e7-8353-5d4eb65dfd6a.png)
```
--primary: #09F;
--text: #CCC;
--background: #080808;
--background-elevated: #222;
```

## One Dark
![One Dark](https://user-images.githubusercontent.com/806101/27455546-826b3d88-5752-11e7-8a6b-87285b90eb3e.png)
```
--primary: #61AFEF;
--text: #ABB2BF;
--background: #282C34;
--background-elevated: #3B4048;
```

## Low Contrast
![Low Contrast](https://cloud.githubusercontent.com/assets/7691630/24120352/4ccdedf2-0d82-11e7-8ff7-c88e48b8e917.png)
```
--primary: #CCC;
--text: #999;
--background: #222;
--background-elevated: #444;
```

## Navy
![Navy](https://cloud.githubusercontent.com/assets/7691630/24120353/4cd08c4c-0d82-11e7-851a-4c62340456ad.png)
```
--primary: #FFF;
--text: #CCC;
--background: #225;
--background-elevated: #114;
```

## Hot Dog Stand
![Hot Dog Stand](https://cloud.githubusercontent.com/assets/7691630/24120351/4cca6182-0d82-11e7-8de8-7ab99dcde042.png)
```
--primary: #000;
--text: #FFF;
--background: #F00;
--background-elevated: #FF0;
```