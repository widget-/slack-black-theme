# Mac OSX Automation

## Create a new "App"
This will launch Slack and automate the script install.
(See the picture below.)

Open Automator, and choose 'Application' from the pane that appears.

## Utilities
In the sidebar, there should be an item called 'Utilities'. Click this, and drag a `Run Shell Script` action into the main workflow. 

## Script
Add this to the script.

```sh
# open and let it init (upgrade ... maybe)
open /Applications/Slack.app
# now check to see if it is up to date with our theme!
cd /Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static
$(grep -q slack-black-theme index.js)
if [[ $? == 1 ]]; then
    echo "\n\n$(curl https://cdn.rawgit.com/Artistan/slack-black-theme/master/addEventListener.js)" >> index.js
    echo "\n\n$(curl https://cdn.rawgit.com/Artistan/slack-black-theme/master/addEventListener.js)" >> ssb-interop.js
    # add any sed replacements here if you want a different theme.
    kill `pgrep Slack`
    sleep 2
    open /Applications/Slack.app
fi
```

![Automator](https://i.imgur.com/v3QPpjV.png)

## Save
Then, save the document with a name you'll remember (something like `Slack Automate Theme`) in /Applications, 
and replace Slack in your dock with the `Slack Automate Theme` app that's been created. 
It will launch both Slack and the bash script to update the theme whenever you invoke the application.

## Optionally change the icon of your custom app launcher.

[Instructions for icon changing](https://apple.stackexchange.com/a/372/144132)
