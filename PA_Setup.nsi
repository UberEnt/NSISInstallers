; NSIS installer script for Planetary Annihilation's Launcher.
;
; Copyright (c) 2015 Uber Entertainment, Inc. All rights reserved.
; Authored by Jørgen P. Tjernø <jorgenpt@gmail.com>
;
; Licensed under the MIT license, see the LICENSE file in the current directory.

SetCompressor lzma

; When developing, uncomment this line.
;SetCompress off

RequestExecutionLevel admin
ShowInstDetails hide

!define PRODUCT_NAME "Planetary Annihilation Launcher"
!define SETUP_VERSION "1.0.0.0"

OutFile "PA_Setup.exe"
InstallDir "C:\Games\Uber Entertainment\${PRODUCT_NAME}"
Name "${PRODUCT_NAME}"

;--------------------------------
; Various helpers

!include "FileFunc.nsh"
!include "VCRedist11.nsh"

;--------------------------------
; ModernUI

!define MUI_ICON  "icon_pa_client_alpha.ico"
;!define MUI_HEADERIMAGE
;!define MUI_HEADERIMAGE_BITMAP
;!define MUI_BGCOLOR "000000"
;!define MUI_PAGE_CUSTOMFUNCTION_PRE "ChangeHeaderColor"

!include "MUI2.nsh"

;--------------------------------
; Pages

!insertmacro MUI_PAGE_LICENSE "eula.rtf"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY
!insertmacro MUI_PAGE_INSTFILES

;--------------------------------
; Language

!insertmacro MUI_LANGUAGE "English"

;--------------------------------
; Descriptions

LangString DESC_Launcher ${LANG_ENGLISH} "Installs the launcher"
LangString DESC_StartMenu ${LANG_ENGLISH} "Creates a shortcut to the launcher in all users' Start Menus"
LangString DESC_Desktop ${LANG_ENGLISH} "Creates a shortcut to the launcher on all users' Desktops"

;--------------------------------
; Executable metadata

VIProductVersion "${SETUP_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductName" "${PRODUCT_NAME} Setup"
VIAddVersionKey /LANG=${LANG_ENGLISH} "ProductVersion" "${SETUP_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "CompanyName" "Uber Entertainment"
VIAddVersionKey /LANG=${LANG_ENGLISH} "LegalCopyright" "Copyright (c) Uber Entertainment"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileVersion" "${SETUP_VERSION}"
VIAddVersionKey /LANG=${LANG_ENGLISH} "FileDescription" "${PRODUCT_NAME} Setup"

;--------------------------------
; Variables

Var FORCEDEPENDENCIES

;--------------------------------
; Functions & Macros

Function .onInit
    ; Set up /FORCEDEPENDENCIES command line option, used in the SkipIfForceDependencies macro.
    StrCpy "$FORCEDEPENDENCIES" "0"
    ${GetOptions} "$CMDLINE" "/FORCEDEPENDENCIES" $0
    IfErrors +2
        StrCpy "$FORCEDEPENDENCIES" "1"
FunctionEnd

Function "ChangeHeaderColor"
  GetDlgItem $r3 $HWNDPARENT 1037
  SetCtlColors $r3 0xFFFFFF "${bg_color}"
  GetDlgItem $r3 $HWNDPARENT 1038
  SetCtlColors $r3 0xFFFFFF "${bg_color}"
FunctionEnd

!macro SetStatus Status
    SetDetailsPrint textonly
    DetailPrint "${Status}"
    SetDetailsPrint lastused
!macroend

!macro MessageBoxIfError Message
    IfErrors 0 +2
        MessageBox MB_OK|MB_ICONSTOP "${Message}"
!macroend

!macro SkipIfForceDependencies Label
    StrCmp $FORCEDEPENDENCIES "1" ${Label}
!macroend

;--------------------------------
; Sections

Section "-Visual C++ Redistributable for Visual Studio 2012 Update 4"
    SetDetailsPrint listonly
    !insertmacro InstallVCRedist11_32bit "$TEMP\PALauncherSetup"
SectionEnd

; This is not needed for the launcher (since it's 32-bit only), but it's needed for the game.
Section "-Visual C++ Redistributable for Visual Studio 2012 Update 4 (64-bit)"
    SetDetailsPrint listonly
    !insertmacro InstallVCRedist11_64bit "$TEMP\PALauncherSetup"
SectionEnd

Section "-DirectX 9.0c (June 2010) Redistributable"
    SetDetailsPrint listonly

    !insertmacro SetStatus "Extracting DirectX 9.0c Redistributable"
    SetOutPath $TEMP\PALauncherSetup
    File /r dxredist

    !insertmacro SetStatus "Installing DirectX 9.0c Redistributable"
    ClearErrors
    ExecWait '"$TEMP\PALauncherSetup\dxredist\dxsetup.exe" /silent'
    !insertmacro MessageBoxIfError "Failed to install DirectX 9.0c Redistributable."
SectionEnd

Section "PA Launcher" SecLauncher
    SetDetailsPrint listonly
    SectionIn RO
    SetOutPath $INSTDIR

    !insertmacro SetStatus "Extracting PA Launcher"
    File "PALauncher.exe"
SectionEnd

Section "Start Menu Shortcut" SecStartMenu
    SetDetailsPrint listonly
    !insertmacro SetStatus "Creating Start Menu shortcut"
    SetShellVarContext all
    CreateDirectory "$SMPROGRAMS\Planetary Annihilation"
    CreateShortcut "$SMPROGRAMS\Planetary Annihilation\${PRODUCT_NAME}.lnk" "$INSTDIR\PALauncher.exe"
    SetShellVarContext current
SectionEnd

Section "Desktop Shortcut" SecDesktop
    SetDetailsPrint listonly
    !insertmacro SetStatus "Creating Desktop shortcut"
    SetShellVarContext all
    CreateShortcut "$DESKTOP\PA Launcher.lnk" "$INSTDIR\PALauncher.exe"
    SetShellVarContext current
SectionEnd

Section "-Redistributable Cleanup"
    SetDetailsPrint listonly
    !insertmacro SetStatus "Cleaning up temporary files"
    RMDir /r "$TEMP\PALauncherSetup"
    SetDetailsPrint both
SectionEnd

;--------------------------------
; Configure section descriptions

!insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
  !insertmacro MUI_DESCRIPTION_TEXT ${SecLauncher} $(DESC_Launcher)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecStartMenu} $(DESC_StartMenu)
  !insertmacro MUI_DESCRIPTION_TEXT ${SecDesktop} $(DESC_Desktop)
!insertmacro MUI_FUNCTION_DESCRIPTION_END
