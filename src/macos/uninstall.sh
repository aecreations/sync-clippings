#!/bin/bash

PRODUCT=SyncClippings
VERSION=1.2.0
IDENTIFIER=io.aecreations.$PRODUCT

uninstErr=0

# ANSI colors
bold='\033[1m'
blue='\033[94m'
red='\033[91m'
reset='\033[0m'

echo
echo -e "${bold}Welcome to the Sync Clippings Helper Uninstaller${reset}"

echo
echo "Sync Clippings Helper $VERSION will be uninstalled."
while true; do
    read -p "Do you wish to continue (y/n)? " answer
    [[ $answer == "y" || $answer == "Y" ]] && break
    [[ $answer == "n" || $answer == "N" ]] && exit 0
    echo "Please answer with 'y' or 'n'"
done

# Delete application folder
echo
echo "Elevated permissions required to delete the application folder."
echo "If prompted, enter your login password."

[ -e "/Library/${PRODUCT}/${VERSION}" ] && sudo rm -rf "/Library/${PRODUCT}/${VERSION}"
if [ $? -eq 0 ]; then
  echo "Deleted application folder"
else
  uninstErr=1
  echo "[ERROR] Could not delete application folder" >&2
fi

# Unregister package information
sudo pkgutil --forget $IDENTIFIER > /dev/null 2>&1
if [ $? -eq 0 ]; then
  echo "Unregistered application information"
else
  uninstErr=1
  echo "[ERROR] Could not delete application information" >&2
fi

# Perform additional cleanup
nativeManifestFile=/Library/Application\ Support/Mozilla/NativeMessagingHosts/syncClippings.json
sudo rm -f "$nativeManifestFile"
if [ $? -eq 0 ]; then
    echo "Deleted application manifest file for Sync Clippings Helper"
else
    uninstErr=1
    echo "[ERROR] Could not delete application manifest file for Sync Clippings Helper" >&2
fi

configFiles=~/Library/Preferences/syncClippings.*
sudo rm -f $configFiles
if [ $? -eq 0 ]; then
    echo "Deleted Sync Clippings Helper settings files"
else
    uninstErr=1
    echo "[ERROR] Could not delete Sync Clippings Helper settings files" >&2
fi

exitStatus=0
echo
if [ $uninstErr -eq 1 ]; then
    echo -e "${red}Uninstallation of Sync Clippings Helper did not finish successfully."
    echo -e "See the above error messages for details.${reset}"
    exitStatus=1
else
    echo "Sync Clippings Helper has been successfully uninstalled."
fi
echo

exit $exitStatus
