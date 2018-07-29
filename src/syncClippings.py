#!/usr/bin/env python3
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

import sys
import json
import struct
import configparser

debug = True

appName = "Sync Clippings"
appInternalName = "syncClippings"
appVer = "1.0a0+"
confFilename = "syncClippings.ini"
syncFilename = "clippings-sync.json"
defaultClippingsData = {
    "version": "6.0",
    "createdBy": "Sync Clippings",
    "userClippingsRoot": []
}

def getSyncFilePath():
    conf = configparser.ConfigParser()
    conf.read(confFilename)
    return conf["Sync File"]["Path"]

def getAppName():
    return appName

def getAppVer():
    return appVer

def log(msg):
    if debug:
        with open("debug.txt", "a") as file:
            file.write(msg)
            file.write("\n")
    
def getMessage():
    rawLength = sys.stdin.buffer.read(4)
    if len(rawLength) == 0:
        sys.exit(0)
    messageLength = struct.unpack('@I', rawLength)[0]
    message = sys.stdin.buffer.read(messageLength).decode('utf-8')
    jsonDict = json.loads(message)   
    return jsonDict

def encodeMessage(messageContent):
    encodedContent = json.dumps(messageContent).encode('utf-8')
    encodedLength = struct.pack('@I', len(encodedContent))
    return {'length': encodedLength, 'content': encodedContent}

def sendMessage(encodedMessage):
    sys.stdout.buffer.write(encodedMessage['length'])
    sys.stdout.buffer.write(encodedMessage['content'])
    sys.stdout.buffer.flush()

    
while True:
    msg = getMessage()
    resp = None

    if "msgID" not in msg:
        err = "Error: expected key 'msgID' does not exist!"
        log(err)
        sys.stderr.buffer.write("%s: %s" % (appInternalName, err))
        sys.stderr.buffer.flush()
        sys.exit(1)

    log("Value of key 'msgID' from 'msg' dictionary: %s" % msg["msgID"])
    
    if msg["msgID"] == "get-app-version":
        resp = {
            "appName": getAppName(),
            "appVersion": getAppVer()
        }
    elif msg["msgID"] == "get-sync-file-path":
        resp = {
            "syncFilePath": getSyncFilePath()
        }

    if resp != None:
        sendMessage(encodeMessage(resp))

