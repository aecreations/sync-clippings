#!/bin/bash
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

srcFilename=syncClippings-setup.sh

# Extract version number from Python script
quotedAppVer=`grep 'APP_VER = ' syncClippings.py | awk -F' = ' '{ print $2 }'`
trimAppVer=${quotedAppVer:1}
appVer=${trimAppVer%%?}

distFilename="syncClippings-${appVer}-setup.sh"
tarFilename="syncClippings-${appVer}-setup.tar"
checksumFile="sha256sum"

cp $srcFilename $distFilename
tar -cf $tarFilename $distFilename
gzip ${tarFilename}
shasum --algorithm=256 ${tarFilename}.gz > $checksumFile
shasum --algorithm=256 --check $checksumFile
