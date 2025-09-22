@echo off
REM ===============================================================
REM Copyright (c) Meta Platforms, Inc. and affiliates.
REM All rights reserved.
REM Modifications Copyright (c) 2025, Scott Kirvan, Aemulus-XR
REM
REM This source code is licensed under the MIT license found in the
REM LICENSE file in the root directory of this source tree.
REM ===============================================================

REM ===================================================================
REM file:: package_project_for_upload.bat
REM Automated package upload script
REM
REM This batch script automates the process of preparing and uploading
REM a build for a Quest application.
REM ===================================================================

call "%~dp0config.bat" || (
    EXIT /B 1
)

PUSHD "%MY_SHIPPING_DIR%" || (
    echo Failed to change to release directory.
    EXIT /B 1
)

set MY_APP_VERSION=
for %%F in (Android_ASTC\main.*.%MY_PACKAGE_NAME%.*) do (
    REM ~nF strips the file extension, so "main.2.com.meta.OBBSample" remains
    REM Then parse using "." as a delimiter and retrieve the second token ("2")
    for /f "tokens=2 delims=." %%G in ("%%~nF") do (
        set MY_APP_VERSION=%%G
    )
)

if "%MY_APP_VERSION%" == "" (
    echo Error: Failed to determine app version.
    POPD
    EXIT /B 1
)

if not exist assets_dir (
    echo "making assets_dir"
    mkdir assets_dir || (
        echo Error: Failed to make assets_dir
        POPD
        EXIT /B 1
    )
)

echo "required file" > assets_dir\required_file.txt

rem Try to copy patch files if they exist, but continue if they don't
for %%F in (Android_ASTC\patch.%MY_APP_VERSION%.*.obb) do (
    copy "%%F" assets_dir > nul 2>&1
    if errorlevel 1 (
        echo Warning: Failed to copy %%F to assets_dir
    ) else (
        echo Copied %%F to assets_dir
    )
)

powershell -File "%~dp0\scripts\GenUploadConfigJSON.ps1" -InputDir assets_dir -OutputFile config-file.json

echo "optional file" > assets_dir\optional_file.txt

REM now upload the build to the Oculus platform

"%OVRPLATFORM_UTIL_EXE%" upload-quest-build --app_id %MY_APP_ID% --app_secret %MY_APP_SECRET% --apk ./Android_ASTC/%UNREAL_UPROJECT_NAME%-Android-Shipping-arm64.apk --obb ./Android_ASTC/main.%MY_APP_VERSION%.%MY_PACKAGE_NAME%.obb --assets_dir ./assets_dir --asset_files_config ./config-file.json -c "%MY_RELEASE_CHANNEL%" --age-group %MY_AGE_GROUP% --notes "%RELEASE_NOTES%"


POPD
