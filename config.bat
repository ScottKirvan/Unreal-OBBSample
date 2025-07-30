REM ===============================================================
REM Copyright (c) Meta Platforms, Inc. and affiliates.
REM All rights reserved.
REM
REM This source code is licensed under the MIT license found in the
REM LICENSE file in the root directory of this source tree.
REM ===============================================================

REM from https://developers.meta.com/horizon/manage/applications/YourApp
SET MY_APP_ID=
SET MY_APP_SECRET=
REM set MY_PACKAGE_NAME to a globally unique Android package name, i.e. com.MyCompany.UnrealOBBSample
SET MY_PACKAGE_NAME=
REM path to your UE5.0+ install, i.e. C:\GitRepos\UnrealEngine
set UNREAL_DIR=

REM This is included in the Meta Quest Developer Hub,
REM or get this here: https://developers.meta.com/horizon/resources/publish-reference-platform-command-line-utility/
SET "OVRPLATFORM_UTIL_EXE=%APPDATA%\odh\ovr-platform-util.exe"

REM e.g. c:\Path\To\Android Studio\jbr\bin\keytool.exe
set "KEYTOOL_PATH=%JAVA_HOME%\bin\keytool.exe"

REM ===============================================================
REM Below this line, you probably don't need to change anything
REM ===============================================================

SET MY_KEYSTORE_ALIAS=MyKey
SET MY_KEYSTORE_PASSWORD=123456

set "UNREALEDITOR_CMD_EXE=%UNREAL_DIR%\Engine\Binaries\Win64\UnrealEditor-Cmd.exe"
set "RUNAUT_BAT=%UNREAL_DIR%\Engine\Build\BatchFiles\RunUAT.bat"

SET "DEFAULT_ENGINE_INI_FILE=%~dp0\Config\DefaultEngine.ini"

SET MY_RELEASE_CHANNEL=ALPHA
SET "MY_SHIPPING_DIR=%~dp0Shipping"

REM ===============================================================
REM Validation
REM ===============================================================

if "%MY_APP_ID%"=="" (
    echo Config Error: Please set MY_APP_ID in %~f0.
    EXIT /B 1
)

if "%MY_APP_SECRET%"=="" (
    echo Config Error: Please set MY_APP_SECRET in %~f0.
    EXIT /B 1
)

if "%MY_PACKAGE_NAME%"=="" (
    echo Config Error: Please set MY_PACKAGE_NAME in %~f0 to something like com.foo.bar.
    EXIT /B 1
)

if not exist "%OVRPLATFORM_UTIL_EXE%" (
    echo Config Error: Could not find ovr-platform-util.exe at %OVRPLATFORM_UTIL_EXE%. check the path in %~f0.
    EXIT /B 1
)

if not exist "%KEYTOOL_PATH%" (
    echo Config Error: Could not find keytool.exe at %KEYTOOL_PATH%. check the path in %~f0, this was a guess from JAVA_HOME.
    EXIT /B 1
)

if not exist "%DEFAULT_ENGINE_INI_FILE%" (
    echo Config Error: Could not find DefaultEngine.ini at %DEFAULT_ENGINE_INI_FILE%. check the path in %~f0.
    EXIT /B 1
)

if not exist "%UNREALEDITOR_CMD_EXE%" (
    echo Config Error: Could not find UnrealEditor-Cmd.exe at %UNREALEDITOR_CMD_EXE%. check the path in %~f0.
    EXIT /B 1
)

if not exist "%RUNAUT_BAT%" (
    echo Config Error: Could not find RunUAT.bat at %RUNAUT_BAT%. check the path in %~f0.
    EXIT /B 1
)

REM change to the directory of this script
cd /D "%~dp0"
