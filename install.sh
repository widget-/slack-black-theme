#!/bin/bash
#
# Slack Custom Theme Installer
# Harry Kantas, 2019
# Version 1.0

OS="$(uname -s)"
case "$OS" in
	"Darwin")
		DEST_DIR="/Applications/Slack.app/Contents/Resources/app.asar.unpacked/src/static"
		;;
	*)
		echo "Your OS is not supported by this installer yet."
		echo "Try installing the themes manually, following the README."
		exit 1
esac

DEST_FILE1="index.js"
DEST_FILE2="ssb-interop.js"

THEMES=("default" "one_dark" "low_contrast" "navy" "hot_dog_stand")

usage() {
cat << EOF
Usage:
	$0 -t <$(echo "${THEMES[@]}" | tr " " "|")>
 	$0 -u

 -t: theme to install.
 -u: revert to the default Slack theme.

Note: You will have to re-run this script whenever you upgrade Slack.
EOF
exit 1
}

uninstall_theme() {
	for file in $DEST_FILE1 $DEST_FILE2
	do
		if [[ $(grep -c "CUSTOM THEMES CONFIG" $DEST_DIR/$file) -gt 0 ]]
		then
			sed -i '' -e '/^\/\/ CUSTOM THEMES CONFIG$/,$d' $DEST_DIR/$file
		fi
	done
}

install_theme() {
	for file in $DEST_FILE1 $DEST_FILE2
	do
		cat $1.js >> $DEST_DIR/$file
	done
}

while getopts "t:u" o; do
  case "${o}" in
    t)
			t="${OPTARG}"
			if [[ $(echo "${THEMES[@]}" | grep -o "$t" | wc -w) -gt 0 ]]
			then
				uninstall_theme
      	install_theme "$t"
			else
				echo "Theme not found!"
				echo
				usage
			fi
      ;;
    u)
			t="original"
      uninstall_theme
      ;;
    *)
      usage
      ;;
  esac
done
if [[ "$#" -eq 0 ]]; then usage; fi
if [[ -z "$t" ]]; then usage; fi

echo "Restart Slack for changes to take effect."
exit 0
