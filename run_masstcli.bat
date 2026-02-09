@echo off
setlocal ENABLEDELAYEDEXPANSION

echo ================================
echo MASSTCLI Scan Started (Windows)
echo ================================

REM --- Configure Android SDK ---
set ANDROID_HOME=C:\Users\Snehal Bugsmirror\AppData\Local\Android\Sdk
set PATH=%PATH%;%ANDROID_HOME%\platform-tools;%ANDROID_HOME%\build-tools\34.0.0;%ANDROID_HOME%\cmdline-tools\latest\bin

REM --- Verify Android SDK ---
if not exist "%ANDROID_HOME%" (
    echo ERROR: Android SDK not found at %ANDROID_HOME%
    echo Please install Android SDK first
    exit /b 1
)

REM --- Install android-35 platform if missing ---
echo Checking for android-35 platform...
"%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat" --list_installed | findstr "platforms;android-35" >nul
if errorlevel 1 (
    echo Installing android-35 platform...
    echo y | "%ANDROID_HOME%\cmdline-tools\latest\bin\sdkmanager.bat" "platforms;android-35"
)

REM --- DEBUG: Search for AAB files ---
echo.
echo ================================
echo DEBUG: Searching for .aab files
echo ================================
dir /s /b "C:\Users\Snehal Bugsmirror\.jenkins\workspace\Jenkins-Masst-CLI\*.aab"
echo.

REM --- DEBUG: Search for APK files ---
echo ================================
echo DEBUG: Searching for .apk files
echo ================================
dir /s /b "C:\Users\Snehal Bugsmirror\.jenkins\workspace\Jenkins-Masst-CLI\*.apk"
echo.

REM --- Resolve root directory ---
set ROOT_DIR=%~dp0..
set TOOLS_DIR=%ROOT_DIR%\tools
set MASSTCLI_DIR=%TOOLS_DIR%\MASSTCLI
set ARTIFACTS_DIR=%ROOT_DIR%\artifacts
set MASST_ZIP=%TOOLS_DIR%\MASSTCLI.zip
set MASST_URL=https://example.com/MASSTCLI.zip

REM --- DEBUG: Show resolved paths ---
echo ================================
echo DEBUG: Resolved Paths
echo ================================
echo ROOT_DIR: %ROOT_DIR%
echo ARTIFACTS_DIR: %ARTIFACTS_DIR%
echo.

REM --- Create tools folder ---
if not exist "%TOOLS_DIR%" (
    mkdir "%TOOLS_DIR%"
)

REM --- Download MASSTCLI if missing ---
if not exist "%MASSTCLI_DIR%\MASSTCLI.exe" (
    echo MASSTCLI not found. Downloading...

    powershell -Command ^
      "Invoke-WebRequest -Uri '%MASST_URL%' -OutFile '%MASST_ZIP%'"

    powershell -Command ^
      "Expand-Archive -Force '%MASST_ZIP%' '%MASSTCLI_DIR%'"

    del "%MASST_ZIP%"
)

REM --- Validate tool ---
if not exist "%MASSTCLI_DIR%\MASSTCLI.exe" (
    echo ERROR: MASSTCLI download failed
    exit /b 1
)

REM --- Scan APKs ---
if exist "%ARTIFACTS_DIR%\*.apk" (
    for %%f in ("%ARTIFACTS_DIR%\*.apk") do (
        echo --------------------------------
        echo Scanning APK: %%~nxf
        "%MASSTCLI_DIR%\MASSTCLI.exe" ^
            -input="%%f" ^
            -config="%MASSTCLI_DIR%\config.bm" ^
            -v=true
    )
) else (
    echo No APK files found in %ARTIFACTS_DIR%
)

REM --- Scan AABs ---
if exist "%ARTIFACTS_DIR%\*.aab" (
    for %%f in ("%ARTIFACTS_DIR%\*.aab") do (
        echo --------------------------------
        echo Scanning AAB: %%~nxf
        "%MASSTCLI_DIR%\MASSTCLI.exe" ^
            -input="%%f" ^
            -config="%MASSTCLI_DIR%\config.bm" ^
            -v=true
    )
) else (
    echo No AAB files found in %ARTIFACTS_DIR%
)

echo ================================
echo MASSTCLI Scan Completed
echo ================================

endlocal