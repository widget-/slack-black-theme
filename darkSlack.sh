#! /usr/bin/env bash

# Originally written by smitt04 in https://github.com/widget-/slack-black-theme/issues/98#issuecomment-511449693
# Extended for slack 3/4 recognition by Nockiro
# Extended with custom styles and only for mac/slack 4 by mliq

OSX_SLACK_RESOURCES_DIR="/Applications/Slack.app/Contents/Resources"

if [[ -d $OSX_SLACK_RESOURCES_DIR ]]; then SLACK_RESOURCES_DIR=$OSX_SLACK_RESOURCES_DIR; fi

APP_VER="app-4"
SLACK_FILE_PATH_4="${SLACK_RESOURCES_DIR}"/app.asar.unpacked/dist/ssb-interop.bundle.js

echo "Got app version ${APP_VER}"
if [[ $APP_VER == app-4* ]]; then

	echo "Updating Slack 4 code.."
	# Check if commands exist
	if ! command -v node >/dev/null 2>&1; then
	  echo "Node.js is not installed. Please install before continuing."
	  exit 1
	fi
	if ! command -v npm >/dev/null 2>&1; then
	  echo "npm is not installed. Please install before continuing."
	  exit 1
	fi
	if ! command -v npx >/dev/null 2>&1; then
	  echo "npx is not installed. run `npm i -g npx` to install."
	  exit 1
	fi
	if ! command -v asar >/dev/null 2>&1; then
	  echo "asar is not installed. run `npm i -g asar` to install."
	  exit 1
	fi
	echo ""
	echo "This script requires sudo privileges." && echo "You'll need to provide your password."

	# sudo npx asar extract "${SLACK_RESOURCES_DIR}"/app.asar "${SLACK_RESOURCES_DIR}"/app.asar.unpacked
# Manually open ssb-interop.bundle.js and clear existing code. Above only good on fresh Slack.
	cat interjectCode.js | sudo tee -a "${SLACK_FILE_PATH_4}" > /dev/null

	sudo npx asar pack "${SLACK_RESOURCES_DIR}"/app.asar.unpacked "${SLACK_RESOURCES_DIR}"/app.asar
fi

echo ""
echo "Slack Updated! Refresh or reload slack to see changes"
