#! /usr/bin/env bash

OSX_SLACK_RESOURCES_DIR="/Applications/Slack.app/Contents/Resources"
LINUX_SLACK_RESOURCES_DIR="/usr/lib/slack/resources"

if [[ -d $OSX_SLACK_RESOURCES_DIR ]]; then SLACK_RESOURCES_DIR=$OSX_SLACK_RESOURCES_DIR; fi
if [[ -d $LINUX_SLACK_RESOURCES_DIR ]]; then SLACK_RESOURCES_DIR=$LINUX_SLACK_RESOURCES_DIR; fi
if [[ -z $SLACK_RESOURCES_DIR ]]; then
	# First: Assume we are on wsl
	SLACK_RESOURCES_DIR=$(wslpath $(cmd.exe /C "echo %LOCALAPPDATA%") | cut -d$'\r' -f1)
	# If that didn't work, try a more generic approach for the bash
	if [[ -z $SLACK_RESOURCES_DIR ]]; then
		SLACK_RESOURCES_DIR=$(cmd.exe /C "cd /D %LOCALAPPDATA% && bash.exe -c pwd")
	fi

	# Find latest version installed
	APP_VER=$(ls -dt ${SLACK_RESOURCES_DIR}/slack/app-[2-9]*)
	set -- "$(echo $APP_VER)"
	IFS='/' read -a APP_VER_ARR <<< "$1"
	APP_VER=${APP_VER_ARR[-1]}

	
	SLACK_RESOURCES_DIR="${SLACK_RESOURCES_DIR}/slack/${APP_VER}/resources"
	echo $SLACK_RESOURCES_DIR
fi

# on "real" unix systems, there is no version number in the path - so we ask the user
if [ -z "$APP_VER" ]; then
	read -p "Enter your slack version (only major, e.g, 4 or 3): " APP_VER
	APP_VER = "app-${SLACK_RESOURCES_DIR}"
fi

SLACK_FILE_PATH_3="${SLACK_RESOURCES_DIR}"/app.asar.unpacked/src/static/index.js
SLACK_FILE_PATH_3_1="${SLACK_RESOURCES_DIR}"/app.asar.unpacked/src/static/ssb-interop.js
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
	echo ""
	echo "This script requires sudo privileges." && echo "You'll need to provide your password."

	sudo npx asar extract "${SLACK_RESOURCES_DIR}"/app.asar "${SLACK_RESOURCES_DIR}"/app.asar.unpacked

	sudo tee -a "${SLACK_FILE_PATH_4}" > /dev/null <<< $(cat interjectCode.js)

	sudo npx asar pack "${SLACK_RESOURCES_DIR}"/app.asar.unpacked "${SLACK_RESOURCES_DIR}"/app.asar
fi

if [[ $APP_VER == app-3* ]]; then
	echo "Updating Slack 3 code.."
	sudo tee -a "${SLACK_FILE_PATH_3}" > /dev/null <<< $(cat interjectCode.js)
	sudo tee -a "${SLACK_FILE_PATH_3_1}" > /dev/null <<< $(cat interjectCode.js)
fi

echo ""
echo "Slack Updated! Refresh or reload slack to see changes"