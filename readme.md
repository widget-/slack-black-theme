# Slack Black Theme

A darker, more contrasty, Slack theme.

# Preview

![Screenshot](https://cloud.githubusercontent.com/assets/7691630/24120350/4cbb643e-0d82-11e7-8353-5d4eb65dfd6a.png)

# Installing into Slack

Find your Slack's application directory.

* Windows: `%homepath%\AppData\Local\slack\`
* Mac: `/Applications/Slack.app/Contents/`
* Linux: `/usr/lib/slack/` (Debian-based)

Open up the most recent version (e.g. `app-2.5.1`) then open
`resources\app.asar.unpacked\src\static\index.js`

## Notice 
You may edit any of the theme colors using the custom CSS (for
the already-custom theme.) Also, you can put any CSS URL you want here,
so you don't necessarily need to create an entire fork to change some small styles.

## Manual js addition
You'll have to do this every time Slack updates.

At the very bottom, add this js.

[addEventListener JavaScript](addEventListener.js)

## Automate js addition
- [x] Windows 10: [Shortcut](automate-windows10.md)
- [x] Mac: [Automator](automate-mac.md)
- [ ] Linux: TODO

## That's it! 
Restart Slack and see how well it works.

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
