@echo off
setlocal ENABLEDELAYEDEXPANSION

echo ================================
echo MASSTCLI Scan Started (Windows)
echo ================================

REM --- Resolve root directory ---
set ROOT_DIR=%~dp0..
set TOOLS_DIR=%ROOT_DIR%\tools
set MASSTCLI_DIR=%TOOLS_DIR%\MASSTCLI
set ARTIFACTS_DIR=%ROOT_DIR%\artifacts
set MASST_ZIP=%TOOLS_DIR%\MASSTCLI.zip
set MASST_URL=https://example.com/MASSTCLI.zip

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
    echo No APK files found
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
    echo No AAB files found
)

echo ================================
echo MASSTCLI Scan Completed
echo ================================

endlocal
