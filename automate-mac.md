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
    addEventListener="\n\n$(curl https://cdn.rawgit.com/Artistan/slack-black-theme/master/addEventListener.js)"
    # theme color changes -- here
    echo "$addEventListener" >> index.js
    echo "$addEventListener" >> ssb-interop.js
    kill `pgrep Slack`
    sleep 2
    open /Applications/Slack.app
fi
```

### Optional Color Changes
This is an example of the One Dark theme automated also.
```sh
# theme color changes -- here
addEventListener=$(sed 's/primary: .*;/primary: #61AFEF;/' <<< $addEventListener)
addEventListener=$(sed 's/text: .*;/text: #ABB2BF;/' <<< $addEventListener)
addEventListener=$(sed 's/background: .*;/background: #282C34;/' <<< $addEventListener)
addEventListener=$(sed 's/background-elevated: .*;/background-elevated: #3B4048;/' <<< $addEventListener)
```

![Automator](https://i.imgur.com/v3QPpjV.png)

## Save
Then, save the document with a name you'll remember (something like `Slack Automate Theme`) in /Applications, 
and replace Slack in your dock with the `Slack Automate Theme` app that's been created. 
It will launch both Slack and the bash script to update the theme whenever you invoke the application.

## Optionally change the icon of your custom app launcher.

[Instructions for icon changing](https://apple.stackexchange.com/a/372/144132)
