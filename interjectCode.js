// First make sure the wrapper app is loaded
document.addEventListener("DOMContentLoaded", function() {

   // Then get its webviews
   let webviews = document.querySelectorAll(".TeamView webview");

   // Fetch our CSS in parallel ahead of time
   const cssPath = 'https://raw.githubusercontent.com/Nockiro/slack-black-theme/master/custom.css';
   let cssPromise = fetch(cssPath).then(response => response.text());

   let customCustomCSS = `
   :root {
      --primary: #61AFEF;
    --text: rgb(235, 235, 235);
    --background: #282C34;
    --background-elevated: #3B4048;

   /* These should be less important: */
   --background-hover: rgba(255, 255, 255, 0.1);
   --background-light: rgb(37, 30, 30);
   --background-bright: rgb(66, 66, 66);

   --border-dim: rgb(185, 178, 178);
   --border-bright: var(--primary);

   --text-bright: rgb(255, 255, 255);
   --text-special: var(--primary);

   --scrollbar-background: #000;
   --scrollbar-border: var(--primary);
   }

   .p-unreads_view__header, .p-unreads_view, .p-workspace__primary_view_contents {
      background: var(--background);
   }
   .p-classic_nav__channel_header__subtitle {
      color: var(--text);
   }
   a[aria-label^="NAME_OF_CHANNEL_OR_DIRECT_CONVO_TO_STYLE"]
   {
        --background: #4d0000  !important;
        --text-transform: uppercase  !important;
        --letter-spacing: 2px !important;
        --text-shadow: 1px 1px white;

    }   `

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