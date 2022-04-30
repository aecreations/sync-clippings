# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# NSIS script for Sync Clippings Helper App setup for 32-bit Windows

# --------------------------------
# Include header files

  !include "MUI2.nsh"
  !include "WordFunc.nsh"
  !include "ZipDLL.nsh"

# --------------------------------
# General

  !define APPNAME "Sync Clippings Helper"
  !define APPVER "1.2b2+"

  # Name and file
  Name "${APPNAME}"
  OutFile "SyncClippings-${APPVER}-setup-win32.exe"

  # Default installation folder
  InstallDir "$PROGRAMFILES\Sync Clippings"

  # Get installation folder from registry if available
  InstallDirRegKey HKEY_CURRENT_USER "Software\AE Creations\Sync Clippings" ""

  # Request application privileges 
  RequestExecutionLevel admin # Require admin rights on NT6+ (When UAC is turned on)

  # Version information
  VIAddVersionKey /LANG=0 "ProductName" "Sync Clippings Helper Setup"
  VIAddVersionKey /LANG=0 "ProductVersion" "1.2"
  VIAddVersionKey /LANG=0 "CompanyName" "AE Creations"
  VIAddVersionKey /LANG=0 "FileDescription" "Sync Clippings Helper Setup (32-bit)"
  VIAddVersionKey /LANG=0 "InternalName" "SyncClippings-${APPVER}-setup"
  VIAddVersionKey /LANG=0 "OriginalFilename" "setup-win32.nsi"
  VIAddVersionKey /LANG=0 "FileVersion" "1.2"
  VIAddVersionKey /LANG=0 "PrivateBuild" ""
  VIAddVersionKey /LANG=0 "SpecialBuild" ""
  VIAddVersionKey /LANG=0 "LegalCopyright" ""
  VIAddVersionKey /LANG=0 "LegalTrademarks" ""
  VIAddVersionKey /LANG=0 "Comments" ""
  VIProductVersion 1.2.0.0
  
# --------------------------------
# Interface Settings

  # Support for hi-res displays
  ManifestDPIAware true

  !define MUI_ABORTWARNING
  !define MUI_ICON "setup.ico"
  !define MUI_HEADERIMAGE
  !define MUI_HEADERIMAGE_RIGHT
  !define MUI_HEADERIMAGE_BITMAP "header.bmp"
  !define MUI_UNICON "setup.ico"
  !define MUI_HEADERIMAGE_UNBITMAP "header.bmp"
  BrandingText " "

# --------------------------------
# Custom UI text

  !define MUI_WELCOMEPAGE_TEXT "The Sync Clippings Helper application works quietly in the background to keep your synced clippings updated between Firefox and Thunderbird, or other instances of those applications.$\r$\n$\r$\nSetup will guide you through the installation of the Sync Clippings Helper App.  Click Next to continue."


# --------------------------------
# Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH

# --------------------------------
# Languages and string utils

  !insertmacro MUI_LANGUAGE "English"
  !insertmacro WordReplace

# --------------------------------
# Installer Sections

Section "Install"

  SetOutPath "$INSTDIR"

  # Escape the backslashes in the installation directory for the native app
  # manifest file.
  StrCpy $0 "$INSTDIR"
  ${WordReplace} $0 "\" "#" "+" $0
  ${WordReplace} $0 "#" "\\" "+" $0

  File "syncClippings.zip"
  !insertmacro ZIPDLL_EXTRACT "syncClippings.zip" "$INSTDIR" "<ALL>"

  # Generate the native app manifest file.
  FileOpen $4 "$INSTDIR\syncClippings.json" w
  FileWrite $4 '{$\r$\n'
  FileWrite $4 '  "name": "syncClippings",$\r$\n'
  FileWrite $4 '  "description": "Sync Clippings",$\r$\n'
  FileWrite $4 '  "path": "$0\\syncClippings.exe",$\r$\n'
  FileWrite $4 '  "type": "stdio",$\r$\n'
  FileWrite $4 '  "allowed_extensions": [$\r$\n'
  FileWrite $4 '    "{91aa5abe-9de4-4347-b7b5-322c38dd9271}",$\r$\n'
  FileWrite $4 '    "clippings-tb@aecreations.github.io"$\r$\n'
  FileWrite $4 '  ]$\r$\n'
  FileWrite $4 '}$\r$\n'
  FileClose $4

  # Generate the INI file if it doesn't exist.
  FindFirst $1 $2 "$LOCALAPPDATA\Sync Clippings\syncClippings.ini"
  StrCmp $2 "syncClippings.ini" +6 +1
  CreateDirectory "$LOCALAPPDATA\Sync Clippings"
  FileOpen $5 "$LOCALAPPDATA\Sync Clippings\syncClippings.ini" w
  FileWrite $5 '[Sync File]$\r$\n'
  FileWrite $5 'Path = $\r$\n'
  FileClose $5
  FindClose $1

  File "syncClippings.ico"

  WriteRegStr HKEY_CURRENT_USER "Software\Mozilla\NativeMessagingHosts\syncClippings" "" "$INSTDIR\syncClippings.json"

  # Store installation folder
  WriteRegStr HKEY_CURRENT_USER "Software\AE Creations\Sync Clippings" "" $INSTDIR

  # Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  # Registry information for add/remove programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "DisplayName" "Sync Clippings Helper App"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "InstallLocation" "$\"$INSTDIR$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "DisplayIcon" "$\"$INSTDIR\syncClippings.ico$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "Publisher" "AE Creations"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "HelpLink" "https://aecreations.sourceforge.io/clippings/sync.php"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "URLInfoAbout" "https://aecreations.sourceforge.io/clippings/sync.php"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "DisplayVersion" "${APPVER}"
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "EstimatedSize" 10752  # KiB
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "VersionMajor" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "VersionMinor" 0
  
  # There is no option for modifying or repairing the install
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "NoRepair" 1

  # Cleanup
  Delete $INSTDIR\syncClippings.zip

SectionEnd

# --------------------------------
# Uninstaller Section

Section "Uninstall"

  RMDir /r $INSTDIR\tcl
  RMDir /r $INSTDIR\tcl8
  RMDir /r $INSTDIR\tk

  Delete $INSTDIR\*
  RMDir $INSTDIR
  Delete "$LOCALAPPDATA\Sync Clippings\*"
  RMDir "$LOCALAPPDATA\Sync Clippings"

  DeleteRegKey HKEY_CURRENT_USER "Software\Mozilla\NativeMessagingHosts\syncClippings"
  DeleteRegKey /ifempty HKCU "Software\AE Creations\Sync Clippings"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper"

SectionEnd

# EOF

