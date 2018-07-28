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

def getAppVer():
    return appVer

def log(msg):
    if debug:
        with open("debug.txt", "a") as file:
            file.write(msg)
    
def getMessage():
    rawLength = sys.stdin.buffer.read(4)
    if len(rawLength) == 0:
        sys.exit(0)
    messageLength = struct.unpack('@I', rawLength)[0]
    message = sys.stdin.buffer.read(messageLength).decode('utf-8')
    return json.loads(message)

# Encode a message for transmission,
# given its content.
def encodeMessage(messageContent):
    encodedContent = json.dumps(messageContent).encode('utf-8')
    encodedLength = struct.pack('@I', len(encodedContent))
    return {'length': encodedLength, 'content': encodedContent}

# Send an encoded message to stdout
def sendMessageEx(encodedMessage):
    sys.stdout.buffer.write(encodedMessage['length'])
    sys.stdout.buffer.write(encodedMessage['content'])
    sys.stdout.buffer.flush()
    

while True:
    msg = getMessage()
    resp = ""

    log("%s: JSON message received: " % appInternalName)
    log(dumps(msg))
    
    if "msgID" not in msg:
        err = "Error: expected key 'msgID' does not exist!"
        log(err)
        sys.stderr.buffer.write("%s: %s" % (appInternalName, err))
        sys.stderr.buffer.flush()
        sys.exit(1)
    
    if msg["msgID"] == "get-app-version":
        resp = getAppVer()

    if resp != "":
        sendMessageEx(encodeMessage(resp))
