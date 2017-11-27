# Slack Black Theme

A darker, more contrasty, Slack theme.

## Preview

![Screenshot][101]


## Table of Contents

|SN|HEADING|SUBHEADING|
|---|---|---|
| |[TITLE][1]| |
|1.|[Preview][10]| |
|2.|[Table of Contents][20]| |
|3.|[Installing into Slack][30]| |
|4.|[Color Schemes][40]| |
|4.1| |[Default][41]|
|4.2| |[One Dark][42]|
|4.3| |[Low Contrast][43]|
|4.4| |[Navy][44]|
|4.5| |[Hot Dog Stand][45]|
|5|[Automatic Application][50]| |
|5.1| |[Windows][51]|
|6.|[Development][60]| |
|7.|[License][70]| |

## Installing into Slack

Find your Slack's application directory.

* Windows: `%homepath%\AppData\Local\slack\`
* Mac: `/Applications/Slack.app/Contents/`
* Linux: `/usr/lib/slack/` (Debian-based)


Open up the most recent version (e.g. `app-2.5.1`) then open
`resources\app.asar.unpacked\src\static\index.js`

At the very bottom, add

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
      --text: #CCC;
      --background: #080808;
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

## Color Schemes

Here's some example color variations you might like.

### Default
![Default][411]
```
--primary: #09F;
--text: #CCC;
--background: #080808;
--background-elevated: #222;
```

### One Dark
![One Dark][421]
```
--primary: #61AFEF;
--text: #ABB2BF;
--background: #282C34;
--background-elevated: #3B4048;
```

### Low Contrast
![Low Contrast][431]
```
--primary: #CCC;
--text: #999;
--background: #222;
--background-elevated: #444;
```

### Navy
![Navy][441]
```
--primary: #FFF;
--text: #CCC;
--background: #225;
--background-elevated: #114;
```

### Hot Dog Stand
![Hot Dog Stand][451]
```
--primary: #000;
--text: #FFF;
--background: #F00;
--background-elevated: #FF0;
```

## Automatic Application

Automatic application of __Slack-Black-Theme__ is available for select platforms.

### Windows

![Automatic application of Slack-Black-Theme, demo on Windows-10][511]

## Development

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

## License

[Apache 2.0][71]



[1]: #slack-black-theme

[10]: #preview
[101]: https://cloud.githubusercontent.com/assets/7691630/24120350/4cbb643e-0d82-11e7-8353-5d4eb65dfd6a.png

[20]: #table-of-contents

[30]: #installing-into-slack

[40]: #color-schemes
[41]: #default
[411]: https://cloud.githubusercontent.com/assets/7691630/24120350/4cbb643e-0d82-11e7-8353-5d4eb65dfd6a.png
[42]: #one-dark
[421]: https://user-images.githubusercontent.com/806101/27455546-826b3d88-5752-11e7-8a6b-87285b90eb3e.png
[43]: #low-contrast
[431]: https://cloud.githubusercontent.com/assets/7691630/24120352/4ccdedf2-0d82-11e7-8ff7-c88e48b8e917.png
[44]: #navy
[441]: https://cloud.githubusercontent.com/assets/7691630/24120353/4cd08c4c-0d82-11e7-851a-4c62340456ad.png
[45]: #hot-dog-stand
[451]: https://cloud.githubusercontent.com/assets/7691630/24120351/4cca6182-0d82-11e7-8de8-7ab99dcde042.png

[50]: #automatic-application
[51]: #windows
[511]: static/img/slack-black-theme-win.gif "Run slack-black-theme-win.bat to automatically apply Slack-Black-Theme on Windows; this demo, on Windows-10"

[60]: #development

[70]: #license
[71]: https://github.com/widget-/slack-black-theme/blob/master/LICENSE