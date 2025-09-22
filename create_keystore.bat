@echo off
REM ===============================================================
REM Copyright (c) Meta Platforms, Inc. and affiliates.
REM All rights reserved.
REM Modifications Copyright (c) 2025, Scott Kirvan, Aemulus-XR
REM
REM This source code is licensed under the MIT license found in the
REM LICENSE file in the root directory of this source tree.
REM ===============================================================

REM ============================================================
REM file:: create_keystore.bat
REM If the keystore doesn't exist, create it.
REM ============================================================

call "%~dp0config.bat" || (
    EXIT /B 1
)

REM DO NOT delete or overwrite an existing keystore. It is needed for signing updates.
REM Create the keystore one time and reuse it.  Once you lose your original keystore, you
REM cannot upload an updated version to the same app on the app store
REM https://gist.github.com/ScottKirvan/8e31195ea44648c9f7e19838d1d86845

REM TODO - make the setup script interactive so users can choose to overwrite or create new if needed

if not exist "Build\Android\" (
    mkdir "Build\Android"
)

if not exist "Build\Android\%MY_KEYSTORE%" (
    echo Keystore not found. Creating new keystore in Build\Android\%MY_KEYSTORE%
    "%KEYTOOL_PATH%" -genkey -v -keystore Build\Android\%MY_KEYSTORE% -alias %MY_KEYSTORE_ALIAS% -keyalg RSA -keysize 2048 -validity 10000 -dname "%MY_KEYSTORE_DNAME%" -storepass %MY_KEYSTORE_PASSWORD% -keypass %MY_KEYSTORE_PASSWORD%
    "%KEYTOOL_PATH%" -list -v -keystore Build\Android\%MY_KEYSTORE% -alias %MY_KEYSTORE_ALIAS% -storepass %MY_KEYSTORE_PASSWORD% -keypass %MY_KEYSTORE_PASSWORD%
)

if not exist "Build\Android\%MY_KEYSTORE%" (
    echo Setup Error: Could not create Build\Android\%MY_KEYSTORE%. 
    EXIT /B 1
)
