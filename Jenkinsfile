pipeline {
    agent any

    environment {
        MASST_DIR = "tools\\MASSTCLI"
        ARTIFACTS_DIR = "artifacts"
        CONFIG_FILE = "config.bm"
        MASST_ZIP = "MASSTCLI.zip"
        MASST_URL = "https://storage.googleapis.com/masst-assets/Defender-Binary-Integrator/1.0.0/Windows/MASSTCLI-v1.1.0-windows-amd64.zip"
    }

    stages {
        stage('Checkout SCM') {
            steps {
                echo 'Checking out source code...'
                checkout scm
            }
        }

        stage('Prepare Tools Directory') {
            steps {
                echo 'Preparing tools directory...'
                bat '''
                    if not exist tools mkdir tools
                '''
            }
        }

        stage('Download MASSTCLI') {
            steps {
                echo 'Downloading MASSTCLI...'
                bat '''
                    if not exist "%MASST_DIR%" (
                        echo Downloading MASSTCLI from %MASST_URL%...
                        powershell -Command "Invoke-WebRequest -Uri '%MASST_URL%' -OutFile '%WORKSPACE%\\%MASST_ZIP%'"

                        echo Extracting MASSTCLI...
                        powershell -Command "$zipPath = Join-Path '%WORKSPACE%' '%MASST_ZIP%'; $destPath = Join-Path '%WORKSPACE%' 'tools'; if (Test-Path $destPath\\MASSTCLI-v1.1.0-windows-amd64) { Remove-Item -Path $destPath\\MASSTCLI-v1.1.0-windows-amd64 -Recurse -Force -ErrorAction SilentlyContinue }; Expand-Archive -LiteralPath $zipPath -DestinationPath $destPath"

                        echo Renaming extracted folder...
                        powershell -Command "if (Test-Path '%WORKSPACE%\\tools\\MASSTCLI-v1.1.0-windows-amd64') { if (Test-Path '%WORKSPACE%\\tools\\MASSTCLI') { Remove-Item '%WORKSPACE%\\tools\\MASSTCLI' -Recurse -Force }; Rename-Item -Path '%WORKSPACE%\\tools\\MASSTCLI-v1.1.0-windows-amd64' -NewName 'MASSTCLI' }"

                        echo Cleaning up zip file...
                        del "%WORKSPACE%\\%MASST_ZIP%"
                    ) else (
                        echo MASSTCLI already exists, skipping download
                    )
                '''
            }
        }

        stage('Verify MASSTCLI') {
            steps {
                echo 'Verifying MASSTCLI installation...'
                bat '''
                    if not exist "%MASST_DIR%\\MASSTCLI.exe" (
                        echo ERROR: MASSTCLI executable not found at %MASST_DIR%\\MASSTCLI.exe
                        dir "%WORKSPACE%\\tools" /s /b | findstr MASSTCLI.exe
                        exit /b 1
                    )
                    echo MASSTCLI verified successfully
                    "%MASST_DIR%\\MASSTCLI.exe" --version || echo MASSTCLI version check completed
                '''
            }
        }

        stage('Verify Artifacts Directory') {
            steps {
                echo 'Verifying artifacts directory...'
                bat '''
                    if not exist "%ARTIFACTS_DIR%" (
                        echo ERROR: Artifacts directory not found
                        exit /b 1
                    )
                    echo Artifacts directory verified
                '''
            }
        }

        stage('Verify Config File') {
            steps {
                echo 'Verifying configuration file...'
                bat '''
                    if not exist "%CONFIG_FILE%" (
                        echo WARNING: Config file %CONFIG_FILE% not found
                        echo Proceeding without config file
                    ) else (
                        echo Config file found: %CONFIG_FILE%
                    )
                '''
            }
        }

        stage('Analyze APK Files') {
            steps {
                echo 'Scanning APK files...'
                script {
                    bat '''
                        set APK_FOUND=0
                        for %%f in ("%ARTIFACTS_DIR%\\*.apk") do (
                            if exist "%%f" (
                                set APK_FOUND=1
                                echo.
                                echo ========================================
                                echo Scanning APK: %%f
                                echo ========================================
                                "%MASST_DIR%\\MASSTCLI.exe" -input="%%f" -config="%CONFIG_FILE%" -v=true
                                if errorlevel 1 (
                                    echo WARNING: Scan failed for %%f
                                )
                            )
                        )
                        if %APK_FOUND%==0 (
                            echo No APK files found in %ARTIFACTS_DIR%
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
                        set AAB_FOUND=0
                        for %%f in ("%ARTIFACTS_DIR%\\*.aab") do (
                            if exist "%%f" (
                                set AAB_FOUND=1
                                echo.
                                echo ========================================
                                echo Scanning AAB: %%f
                                echo ========================================
                                "%MASST_DIR%\\MASSTCLI.exe" -input="%%f" -config="%CONFIG_FILE%" -v=true
                                if errorlevel 1 (
                                    echo WARNING: Scan failed for %%f
                                )
                            )
                        )
                        if %AAB_FOUND%==0 (
                            echo No AAB files found in %ARTIFACTS_DIR%
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
            echo 'Cleaning up workspace...'
            bat '''
                if exist "%WORKSPACE%\\%MASST_ZIP%" del "%WORKSPACE%\\%MASST_ZIP%"
            '''
        }
    }
}