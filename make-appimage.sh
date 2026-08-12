#!/bin/sh

set -eu

ARCH=$(uname -m)
VERSION=$(pacman -Q opentoonz | awk '{print $2; exit}') # example command to get version of application here
export ARCH VERSION
export OUTPATH=./dist
export ADD_HOOKS="self-updater.hook"
export UPINFO="gh-releases-zsync|${GITHUB_REPOSITORY%/*}|${GITHUB_REPOSITORY#*/}|latest|*$ARCH.AppImage.zsync"
export ICON=/usr/share/icons/hicolor/256x256/apps/io.github.OpenToonz.png
export DESKTOP=/usr/share/applications/io.github.OpenToonz.desktop

# change the binary in the .desktop to launch OpenToonz directly
# setup-opentoonz.hook does the same as the opentoonz shell script
sed -i -e 's|Exec=opentoonz|Exec=OpenToonz|g' "$DESKTOP"

# Deploy dependencies
LD_LIBRARY_PATH=/usr/lib/opentoonz quick-sharun \
	/usr/bin/OpenToonz       \
	/usr/bin/tcleanup        \
	/usr/bin/tcomposer       \
	/usr/bin/tconverter      \
	/usr/bin/tfarmcontroller \
	/usr/bin/tfarmserver     \
	/usr/lib/opentoonz       \
	/usr/share/opentoonz     \
	/usr/bin/ffmpeg          \
	/usr/bin/ffprobe         \


# Additional changes can be done in between here

# Turn AppDir into AppImage
quick-sharun --make-appimage

# Test the app for 12 seconds, if the test fails due to the app
# having issues running in the CI use --simple-test instead
quick-sharun --test ./dist/*.AppImage
