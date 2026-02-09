pipeline {
    agent any

    environment {
        MASST_DIR = "MASSTCLI_EXTRACTED"
        ARTIFACTS_DIR = "."
        CONFIG_FILE = "config.bm"
        MASST_ZIP = "MASSTCLI"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Extract MASSTCLI') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    echo 'Extracting MASSTCLI from workspace...'
                    bat '''
                        if not exist "%MASST_DIR%" (
                            echo Extracting MASSTCLI.zip from workspace...

                            if not exist "%WORKSPACE%\\%MASST_ZIP%.zip" (
                                echo ERROR: MASSTCLI.zip not found in workspace!
                                echo Contents of workspace:
                                dir /b "%WORKSPACE%"
                                exit /b 1
                            )

                            echo Extracting to temporary location to avoid path length issues...
                            powershell -Command "$ProgressPreference = 'SilentlyContinue'; if (Test-Path 'C:\\temp\\masstcli_extract') { Remove-Item 'C:\\temp\\masstcli_extract' -Recurse -Force -ErrorAction SilentlyContinue }; New-Item -ItemType Directory -Path 'C:\\temp\\masstcli_extract' -Force | Out-Null; Expand-Archive -LiteralPath '%WORKSPACE%\\%MASST_ZIP%.zip' -DestinationPath 'C:\\temp\\masstcli_extract' -Force"

                            echo Moving extracted files to workspace...
                            powershell -Command "$extractedFolder = Get-ChildItem -Path 'C:\\temp\\masstcli_extract' -Directory | Select-Object -First 1; if ($extractedFolder) { Move-Item -Path $extractedFolder.FullName -Destination '%WORKSPACE%\\%MASST_DIR%' -Force } else { echo 'ERROR: No folder found in extracted archive'; exit 1 }"

                            echo Cleaning up temporary files...
                            powershell -Command "if (Test-Path 'C:\\temp\\masstcli_extract') { Remove-Item 'C:\\temp\\masstcli_extract' -Recurse -Force -ErrorAction SilentlyContinue }"

                        ) else (
                            echo MASSTCLI already extracted, skipping extraction
                        )
                    '''
                }
            }
        }

        stage('Verify MASSTCLI') {
            steps {
                echo 'Verifying MASSTCLI installation...'
                bat '''
                    echo Searching for MASSTCLI executable...

                    set MASST_EXE=
                    for %%f in ("%MASST_DIR%\\MASSTCLI*.exe") do (
                        set MASST_EXE=%%~nxf
                        echo Found executable: %%~nxf
                        goto :found_exe
                    )

                    :found_exe
                    if not defined MASST_EXE (
                        echo ERROR: No MASSTCLI executable found in %MASST_DIR%!
                        echo Contents of extraction directory:
                        dir /s /b "%MASST_DIR%"
                        exit /b 1
                    )

                    echo Running MASSTCLI version check...
                    "%MASST_DIR%\\%MASST_EXE%" --version

                    echo.
                    echo ========================================
                    echo ✅ MASSTCLI extracted and verified successfully
                    echo Executable: %MASST_EXE%
                    echo Location: %MASST_DIR%
                    echo ========================================
                '''
            }
        }

        stage('Analyze APK Files') {
            steps {
                echo 'Scanning APK files...'
                script {
                    bat '''
                        REM Find the MASSTCLI executable
                        set MASST_EXE=
                        for %%f in ("%MASST_DIR%\\MASSTCLI*.exe") do (
                            set MASST_EXE=%%~nxf
                            goto :found_exe_apk
                        )

                        :found_exe_apk
                        if not defined MASST_EXE (
                            echo ERROR: MASSTCLI executable not found!
                            exit /b 1
                        )

                        echo Using executable: %MASST_EXE%
                        echo Scanning directory: %ARTIFACTS_DIR%

                        set APK_FOUND=0
                        for %%f in ("%ARTIFACTS_DIR%\\*.apk") do (
                            if exist "%%f" (
                                set APK_FOUND=1
                                echo.
                                echo ========================================
                                echo Scanning APK: %%f
                                echo ========================================
                                "%MASST_DIR%\\%MASST_EXE%" -input="%%f" -config="%CONFIG_FILE%" -v=true
                                if errorlevel 1 (
                                    echo WARNING: Scan failed for %%f
                                )
                            )
                        )
                        if %APK_FOUND%==0 (
                            echo No APK files found in %ARTIFACTS_DIR%
                            echo Available files:
                            dir /b "%ARTIFACTS_DIR%\\*.apk" 2>nul || echo None
                        )
                    '''
                }
            }
        }

        stage('Analyze AAB Files') {
            steps {
                echo 'Scanning AAB files...'
                script {
                    bat '''
                        REM Find the MASSTCLI executable
                        set MASST_EXE=
                        for %%f in ("%MASST_DIR%\\MASSTCLI*.exe") do (
                            set MASST_EXE=%%~nxf
                            goto :found_exe_aab
                        )

                        :found_exe_aab
                        if not defined MASST_EXE (
                            echo ERROR: MASSTCLI executable not found!
                            exit /b 1
                        )

                        echo Using executable: %MASST_EXE%
                        echo Scanning directory: %ARTIFACTS_DIR%

                        set AAB_FOUND=0
                        for %%f in ("%ARTIFACTS_DIR%\\*.aab") do (
                            if exist "%%f" (
                                set AAB_FOUND=1
                                echo.
                                echo ========================================
                                echo Scanning AAB: %%f
                                echo ========================================
                                "%MASST_DIR%\\%MASST_EXE%" -input="%%f" -config="%CONFIG_FILE%" -v=true
                                if errorlevel 1 (
                                    echo WARNING: Scan failed for %%f
                                )
                            )
                        )
                        if %AAB_FOUND%==0 (
                            echo No AAB files found in %ARTIFACTS_DIR%
                            echo Available files:
                            dir /b "%ARTIFACTS_DIR%\\*.aab" 2>nul || echo None
                        )
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'MASSTCLI pipeline completed successfully!'
        }
        failure {
            echo 'MASSTCLI pipeline failed. Please check the logs above.'
        }
        always {
            echo 'Cleaning up temporary files...'
            bat '''
                powershell -Command "if (Test-Path 'C:\\temp\\masstcli_extract') { Remove-Item 'C:\\temp\\masstcli_extract' -Recurse -Force -ErrorAction SilentlyContinue }"
            '''
        }
    }
}