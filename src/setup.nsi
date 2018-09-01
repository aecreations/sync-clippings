# NSIS script for Sync Clippings Helper App setup for Windows

# --------------------------------
# Include header files

  !include "MUI2.nsh"
  !include "WordFunc.nsh"
  !include "ZipDLL.nsh"

# --------------------------------
# General

  # Name and file
  Name "Sync Clippings Helper"
  OutFile "Sync Clippings Helper Setup.exe"

  # Default installation folder
  # TO DO: For the 64-bit version of the native app, use "$PROGRAMFILES64".
  InstallDir "$PROGRAMFILES\Sync Clippings"

  # Get installation folder from registry if available
  InstallDirRegKey HKCU "Software\AE Creations\Sync Clippings" ""

  # Request application privileges 
  RequestExecutionLevel admin # Require admin rights on NT6+ (When UAC is turned on)

# --------------------------------
# Interface Settings

  !define MUI_ABORTWARNING

# --------------------------------
# Custom UI text

  !define MUI_WELCOMEPAGE_TEXT "Setup will guide you through the installation of the Sync Clippings Helper App.$\r$\n$\r$\n$\r$\nClick Next to continue."


# --------------------------------
# Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
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

  file "syncClippings.zip"

  !insertmacro ZIPDLL_EXTRACT "syncClippings.zip" "$INSTDIR" "<ALL>"

  # Generate the native app manifest file.
  FileOpen $4 "$INSTDIR\syncClippings.json" w
  FileWrite $4 '{$\r$\n'
  FileWrite $4 '  "name": "syncClippings",$\r$\n'
  FileWrite $4 '  "description": "Sync Clippings",$\r$\n'
  FileWrite $4 '  "path": "$0\\syncClippings.exe",$\r$\n'
  FileWrite $4 '  "type": "stdio",$\r$\n'
  FileWrite $4 '  "allowed_extensions": ["{91aa5abe-9de4-4347-b7b5-322c38dd9271}"]$\r$\n'
  FileWrite $4 '}$\r$\n'
  FileClose $4

  # Native app manifest location
  WriteRegStr HKEY_LOCAL_MACHINE "Software\Mozilla\NativeMessagingHosts\syncClippings" "" "$INSTDIR\syncClippings.json"

  # Store installation folder
  WriteRegStr HKEY_CURRENT_USER "Software\AE Creations\Sync Clippings" "" $INSTDIR

  # Create uninstaller
  WriteUninstaller "$INSTDIR\Uninstall.exe"

  # Registry information for add/remove programs
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "DisplayName" "Sync Clippings Helper App"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "UninstallString" "$\"$INSTDIR\uninstall.exe$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "QuietUninstallString" "$\"$INSTDIR\uninstall.exe$\" /S"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "InstallLocation" "$\"$INSTDIR$\""
  #WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "DisplayIcon" "$\"$INSTDIR\logo.ico$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "Publisher" "AE Creations"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "HelpLink" "http://aecreations.sourceforge.net/resources.php"
  #WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "URLUpdateInfo" "$\"${UPDATEURL}$\""
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "URLInfoAbout" "http://aecreations.sourceforge.net/clippings/"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper" "DisplayVersion" "1.0"
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

  Delete "$INSTDIR\*"

  RMDir "$INSTDIR"

  DeleteRegKey HKEY_LOCAL_MACHINE "Software\Mozilla\NativeMessagingHosts\syncClippings"
  DeleteRegKey /ifempty HKCU "Software\AE Creations\Sync Clippings"
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\Sync Clippings Helper"

SectionEnd

# EOF
