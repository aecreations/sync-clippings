#!/bin/bash

#Generate application uninstallers for macOS.

#Parameters
DATE=`date +%Y-%m-%d`
TIME=`date +%H:%M:%S`
LOG_PREFIX="[$DATE $TIME]"

# ANSI colors
bold='\033[1m'
blue='\033[94m'
red='\033[91m'
reset='\033[0m'

#Functions
log_info() {
    echo "${LOG_PREFIX}[INFO]" $1
}

log_warn() {
    echo "${LOG_PREFIX}[WARN]" $1
}

log_error() {
    echo "${LOG_PREFIX}[ERROR]" $1
}

echo
echo -e "${bold}Welcome to the Sync Clippings Helper Uninstaller${reset}"

#Check running user
if (( $EUID != 0 )); then
    echo -e "${red}Elevated permissions required to uninstall. Rerun the uninstaller with sudo.${reset}"
    echo
    exit
fi

echo
echo "Sync Clippings Helper __VERSION__ will be uninstalled."
while true; do
    read -p "Do you wish to continue [Y/n]? " answer
    [[ $answer == "y" || $answer == "Y" || $answer == "" ]] && break
    [[ $answer == "n" || $answer == "N" ]] && exit 0
    echo "Please answer with 'y' or 'n'"
done


#Need to replace these with install preparation script
VERSION=__VERSION__
PRODUCT=__PRODUCT__

echo
echo "Starting uninstallation"
# remove link to shorcut file
find "/usr/local/bin/" -name "__PRODUCT__-__VERSION__" | xargs rm
if [ $? -eq 0 ]
then
  echo "[1/3] [DONE] Successfully deleted shortcut links"
else
  echo "[1/3] [ERROR] Could not delete shortcut links" >&2
fi

#forget from pkgutil
pkgutil --forget "org.$PRODUCT.$VERSION" > /dev/null 2>&1
if [ $? -eq 0 ]
then
  echo "[2/3] [DONE] Successfully deleted application information"
else
  echo "[2/3] [ERROR] Could not delete application information" >&2
fi

#remove application source distribution
[ -e "/Library/${PRODUCT}/${VERSION}" ] && rm -rf "/Library/${PRODUCT}/${VERSION}"
if [ $? -eq 0 ]
then
  echo "[3/3] [DONE] Successfully deleted application"
else
  echo "[3/3] [ERROR] Could not delete application" >&2
fi

# Perform additional cleanup
echo "Deleting configuration files"
nativeManifestFile=/Library/Application\ Support/Mozilla/NativeMessagingHosts/syncClippings.json
rm -f "$nativeManifestFile"

configFiles=~/Library/Preferences/syncClippings.*
rm -f $configFiles

echo
echo "Sync Clippings Helper has been successfully uninstalled."
echo

exit 0
