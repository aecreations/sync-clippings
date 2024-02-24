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
APP_VER = "2.0a0+"
CONF_FILENAME = "syncClippings.ini"
SYNC_FILENAME = "clippings-sync.json"

gDefaultClippingsData = {
    "version": "6.1",
    "createdBy": APP_NAME,
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
    rv = ""
    conf = configparser.ConfigParser()
    confFilePath = getConfigFilePath()
    try:
        conf.read(confFilePath)
        rv = conf["Sync File"]["Path"]
    except:
        # Create config file if it doesn't exist.
        file = open(confFilePath, "w", encoding="utf-8")
        file.close()
        setSyncDir("")
    return rv

def setSyncDir(aPath):
    conf = configparser.ConfigParser()
    confFilePath = getConfigFilePath()
    conf["Sync File"] = { "Path": aPath }
    with open(confFilePath, "w") as configFile:
        conf.write(configFile)
        
def getSyncFileInfo(aSyncFileDir):
    rv = {
        "fileName": "",
        "fileSizeKB": ""
    }
    if not Path(aSyncFileDir).exists():
        log("getSyncFileInfo(): Directory does not exist: %s" % aSyncFileDir)
        return rv
    syncFilePath = Path(aSyncFileDir) / SYNC_FILENAME
    if not syncFilePath.exists():
        log("getSyncFileInfo(): Sync file does not exist at directory %s" % aSyncFileDir)
        return rv
    fileInfo = os.stat(syncFilePath)
    fileSizeBytes = fileInfo.st_size
    rv["fileName"] = SYNC_FILENAME
    # Convert file size to kilobytes, and show 1 decimal place if < 10 KB.
    numDigits = None
    fileSizeKB = int(fileSizeBytes) / 1024
    if fileSizeKB < 10:
        numDigits = 1
    rv["fileSizeKB"] = round(fileSizeKB, numDigits)
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
    
def promptSyncFldrPath():
    rv = ""
    root = tk.Tk()
    root.withdraw()
    root.overrideredirect(True)
    root.geometry('0x0+0+0')
    root.deiconify()
    root.lift()
    root.focus_force()
    # Additional hack for macOS.
    if platform.system() == "Darwin":
        os.system('''/usr/bin/osascript -e 'tell app "Finder" to set frontmost of process "Python" to true' ''')
    homeDir = os.path.expanduser("~")
    rv = filedialog.askdirectory(initialdir=homeDir)
    # On Linux, an empty tuple is returned if user cancelled from file picker.
    if str(rv) == "()":
        rv = ""
    # Get rid of the top-level instance once to make it invisible.
    root.destroy()
    return rv
    
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
        sys.stderr.buffer.write("%s: %s" % (APP_NAME, err))
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
        if path.startswith("~/"):
            path = os.path.expanduser("~") + path[1:len(path)]
        try:
            setSyncDir(path)
            resp = getResponseOK()
        except Exception as e:
            resp = getResponseErr(e)
    elif msg["msgID"] == "get-sync-file-info":
        syncDir = getSyncDir()
        resp = getSyncFileInfo(syncDir)
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
    elif msg["msgID"] == "sync-dir-folder-picker":
        resp = {
            "syncFilePath": promptSyncFldrPath()
        }

    if resp is not None:
        sendMessage(encodeMessage(resp))

