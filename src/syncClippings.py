#!/usr/bin/env python3
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

import os
import platform
import sys
import json
import struct
import configparser
import copy
from pathlib import Path
import tkinter as tk
from tkinter import filedialog

DEBUG = False

APP_NAME = "Sync Clippings"
APP_SNAME = "syncClippings"
APP_VER = "1.0b3"
CONF_FILENAME = "syncClippings.ini"
SYNC_FILENAME = "clippings-sync.json"

gDefaultClippingsData = {
    "version": "6.0",
    "createdBy": "Sync Clippings",
    "userClippingsRoot": []
}


def getAppName():
    return APP_NAME

def getAppVer():
    return APP_VER

def getConfigFilePath():
    rv = None
    osName = platform.system()
    homeDir = os.path.expanduser("~")
    if osName == "Windows":
        rv = homeDir + "\\AppData\\Local\\Sync Clippings\\" + CONF_FILENAME
    elif osName == "Darwin":  # macOS
        rv = homeDir + "/Library/Preferences/" + CONF_FILENAME
    else:
        rv = homeDir + "/.config/sync-clippings/" + CONF_FILENAME
    return rv

def getSyncDir():
    conf = configparser.ConfigParser()
    confFilePath = getConfigFilePath()
    conf.read(confFilePath)
    rv = conf["Sync File"]["Path"]
    return rv

def setSyncDir(aPath):
    conf = configparser.ConfigParser()
    confFilePath = getConfigFilePath()
    conf["Sync File"] = { "Path": aPath }
    with open(confFilePath, "w") as configFile:
        conf.write(configFile)

def getSyncDirFromFolderPickerUI():
    rv = None
    root = tk.Tk()
    root.withdraw()

    # Force the folder picker dialog to appear on top:
    # https://stackoverflow.com/questions/3375227/how-to-give-tkinter-file-dialog-focus
    # Make the root window almost invisible - no decorations, 0 size, top left corner.
    root.overrideredirect(True)
    root.geometry('0x0+0+0')

    # Show window again and lift it to top so it can get focus.
    root.deiconify()
    root.lift()
    root.focus_force()

    # Additional hack for macOS.
    if platform.system() == "Darwin":
        os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')

    fldrPath = filedialog.askdirectory()
    root.destroy()

    osName = platform.system()
    if osName == "Windows":
        rv = fldrPath.replace("/", "\\")
    else:
        rv = fldrPath
        
    return rv
        
def getSyncedClippingsData(aSyncFileDir):
    rv = ""
    if not Path(aSyncFileDir).exists():
        log("getSyncedClippingsData(): Directory does not exist: %s" % aSyncFileDir)
        syncDirPath = Path(aSyncFileDir)
        syncDirPath.mkdir(parents=True)
 
    log("getSyncedClippingsData(): aSyncFileDir: %s" % aSyncFileDir)
    syncFilePath = Path(aSyncFileDir) / SYNC_FILENAME
    if syncFilePath.exists():
        log("getSyncedClippingsData(): Reading sync file '%s'" % syncFilePath)
        file = open(syncFilePath, "r", encoding="utf-8")
        rv = file.read()
    else:
        log("getSyncedClippingsData(): Sync file '%s' not found.\nGenerating new file from template." % syncFilePath)
        fileData = json.dumps(gDefaultClippingsData)
        file = open(syncFilePath, "w", encoding="utf-8")
        file.write(fileData)
        rv = fileData
    if file is not None:
        file.close()
    
    return rv

def updateSyncedClippingsData(aSyncFileDir, aSyncedClippingsData):
    syncData = copy.deepcopy(gDefaultClippingsData)
    syncData["userClippingsRoot"] = aSyncedClippingsData
    syncFileData = json.dumps(syncData)
    syncFilePath = Path(aSyncFileDir) / SYNC_FILENAME
    try:
        file = open(syncFilePath, "w", encoding="utf-8")
        file.write(syncFileData)
    except Exception as e:
        log("updateSyncedClippingsData(): Error writing to sync file '{0}': {1}".format(aSyncFilePath), e.message)
    finally:
        if file is not None:
            file.close()
    
def log(aMsg):
    if DEBUG:
        with open("debug.txt", "a") as file:
            file.write(aMsg)
            file.write("\n")

def getResponseOK():
    rv = { "status": "ok" }
    return rv

def getResponseErr(aErr):
    template = "An exception of type {0} has occurred. Arguments: {1!r}"
    rv = {
        "status": "failure",
        "details": template.format(type(aErr).__name__, aErr.args)
    }
    return rv

def getMessage():
    rawLength = sys.stdin.buffer.read(4)
    if len(rawLength) == 0:
        sys.exit(0)
    messageLength = struct.unpack('@I', rawLength)[0]
    message = sys.stdin.buffer.read(messageLength).decode('utf-8')
    rv = json.loads(message)   
    return rv

def encodeMessage(aMsgContent):
    encodedContent = json.dumps(aMsgContent).encode('utf-8')
    encodedLength = struct.pack('@I', len(encodedContent))
    return {'length': encodedLength, 'content': encodedContent}

def sendMessage(aEncodedMsg):
    sys.stdout.buffer.write(aEncodedMsg['length'])
    sys.stdout.buffer.write(aEncodedMsg['content'])
    sys.stdout.buffer.flush()

    
while True:
    msg = getMessage()
    resp = None

    if "msgID" not in msg:
        err = "Error: expected key 'msgID' does not exist!"
        log(err)
        sys.stderr.buffer.write("%s: %s" % (APP_SNAME, err))
        sys.stderr.buffer.flush()
        sys.exit(1)

    log("Value of key 'msgID' from 'msg' dictionary: %s" % msg["msgID"])
    
    if msg["msgID"] == "get-app-version":
        resp = {
            "appName": getAppName(),
            "appVersion": getAppVer()
        }
    elif msg["msgID"] == "get-sync-dir":
        resp = {
            "syncFilePath": getSyncDir()
        }
    elif msg["msgID"] == "set-sync-dir":
        path = msg["filePath"]
        log("Message 'set-sync-dir': filePath = {0}".format(msg['filePath']))
        try:
            setSyncDir(path)
            resp = getResponseOK()
        except Exception as e:
            resp = getResponseErr(e)
    elif msg["msgID"] == "sync-dir-folder-picker":
        resp = {
            "syncFilePath": getSyncDirFromFolderPickerUI()
        }
    elif msg["msgID"] == "get-synced-clippings":
        syncDir = getSyncDir()
        resp = getSyncedClippingsData(syncDir)
    elif msg["msgID"] == "set-synced-clippings":
        syncDir = getSyncDir()
        syncData = msg["syncData"]
        try:
            updateSyncedClippingsData(syncDir, syncData)
            resp = getResponseOK()
        except Exception as e:
            resp = getResponseErr(e)

    if resp is not None:
        sendMessage(encodeMessage(resp))

