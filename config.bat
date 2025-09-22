REM ===============================================================
REM Copyright (c) Meta Platforms, Inc. and affiliates.
REM All rights reserved.
REM Modifications Copyright (c) 2025, Scott Kirvan, Aemulus-XR
REM
REM This source code is licensed under the MIT license found in the
REM LICENSE file in the root directory of this source tree.
REM ===============================================================

REM ===============================================================
REM file:: config.bat
REM ===============================================================

REM from https://developers.meta.com/horizon/manage/applications/YourApp
SET MY_APP_ID=
SET MY_APP_SECRET=
REM set MY_STORE_COMPANY_NAME to a globally unique, play store friendly, company name, i.e. com.MyCompanyName.MyAppName.feature
SET MY_STORE_COMPANY_NAME=
SET MY_STORE_APPNAME=
REM TODO - add a MY_STORE_FEATURE and append it to MY_PACKAGE_NAME if needed

REM path to your UE5.0+ install, i.e. C:\GitRepos\UnrealEngine
set UNREAL_DIR=
SET UNREAL_UPROJECT_NAME=OBBSample

REM This is included in the Meta Quest Developer Hub,
REM or get this here: https://developers.meta.com/horizon/resources/publish-reference-platform-command-line-utility/
SET "OVRPLATFORM_UTIL_EXE=%APPDATA%\odh\ovr-platform-util.exe"

REM e.g. c:\Path\To\Android Studio\jbr\bin\keytool.exe
set "KEYTOOL_PATH=%JAVA_HOME%\bin\keytool.exe"

SET MY_KEYSTORE=ExampleKey.keystore
SET MY_KEYSTORE_ALIAS=MyKey
SET MY_KEYSTORE_PASSWORD=123456
SET MY_KEYSTORE_DNAME=CN=John Doe, OU=Engineering, O=MyCompany, L=MyCity, ST=MyState, C=US

SET MY_RELEASE_CHANNEL=ALPHA
SET "MY_SHIPPING_DIR=%~dp0Shipping"

REM Path to your release notes text file, e.g. ReleaseNotes.txt
SET "MY_RELEASE_NOTES=ReleaseNotes.txt"
SET MY_AGE_GROUP=TEENS_AND_ADULTS

REM ===============================================================
REM Below this line, you probably don't need to change anything
REM ===============================================================

set "UNREALEDITOR_CMD_EXE=%UNREAL_DIR%\Engine\Binaries\Win64\UnrealEditor-Cmd.exe"
set "RUNAUT_BAT=%UNREAL_DIR%\Engine\Build\BatchFiles\RunUAT.bat"

SET "DEFAULT_ENGINE_INI_FILE=%~dp0\Config\DefaultEngine.ini"

REM globally unique Android package name, i.e. com.companyname.appname.feature
SET MY_PACKAGE_NAME=com.%MY_STORE_COMPANY_NAME%.%MY_STORE_APPNAME%

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

if "%MY_STORE_COMPANY_NAME%"=="" (
    echo Config Error: Please set MY_STORE_COMPANY_NAME in %~f0.
    EXIT /B 1
)

if "%MY_STORE_APPNAME%"=="" (
    echo Config Error: Please set MY_STORE_APPNAME in %~f0.
    EXIT /B 1
)

if "%UNREAL_DIR%"=="" (
    echo Config Error: Please set UNREAL_DIR in %~f0.
    EXIT /B 1
)

if "%UNREAL_UPROJECT_NAME%"=="" (
    echo Config Error: Please set UNREAL_UPROJECT_NAME in %~f0.
    EXIT /B 1
)

if not exist "%~dp0%UNREAL_UPROJECT_NAME%.uproject" (
    echo Config Error: Could not find %UNREAL_UPROJECT_NAME%.uproject at %~dp0%UNREAL_UPROJECT_NAME%.uproject. check the path in %~f0.
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

if "%MY_KEYSTORE%"=="" (
    echo Config Error: Please set MY_KEYSTORE in %~f0.
    EXIT /B 1
)

if "%MY_KEYSTORE_ALIAS%"=="" (
    echo Config Error: Please set MY_KEYSTORE_ALIAS in %~f0.
    EXIT /B 1
)

if "%MY_KEYSTORE_PASSWORD%"=="" (
    echo Config Error: Please set MY_KEYSTORE_PASSWORD in %~f0.
    EXIT /B 1
)

if "%MY_KEYSTORE_DNAME%"=="" (
    echo Config Error: Please set MY_KEYSTORE_DNAME in %~f0.
    EXIT /B 1
)

if "%MY_RELEASE_CHANNEL%"=="" (
    echo Config Error: Please set MY_RELEASE_CHANNEL in %~f0.
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

if "%MY_RELEASE_NOTES%"=="" (
    echo Config Error: Please set MY_RELEASE_NOTES in %~f0.
    EXIT /B 1
)

if not exist "%MY_RELEASE_NOTES%" (
    echo Config Error: Could not find "%MY_RELEASE_NOTES%". Check the path in %~f0.
    EXIT /B 1
)

REM parse the release notes file, escaping quotes and newlines
for /f "delims=" %%I in ('powershell -NoProfile -Command "$content = Get-Content -Path "%MY_RELEASE_NOTES%" -Raw; $content = $content.Replace(\"\\'\", \"\\\\'\").Replace(\"\"\"\", \"\\\"\"\").Replace([Environment]::NewLine, \"\\n\"); Write-Output $content"') do set "RELEASE_NOTES=%%I"

if "%RELEASE_NOTES%"=="" (
    echo Config Error: Error parsing MY_RELEASE_NOTES in %~f0.  File empty?
    EXIT /B 1
)

if "%MY_AGE_GROUP%"=="" (
    echo Config Error: Please set MY_AGE_GROUP in %~f0.
    EXIT /B 1
)

REM change to the directory of this script
cd /D "%~dp0"
