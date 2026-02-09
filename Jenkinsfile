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
                timeout(time: 10, unit: 'MINUTES') {
                    echo 'Downloading MASSTCLI...'
                    bat '''
                        if not exist "%MASST_DIR%\\MASSTCLI.exe" (
                            echo Downloading MASSTCLI from %MASST_URL%...
                            powershell -Command "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri '%MASST_URL%' -OutFile '%WORKSPACE%\\%MASST_ZIP%' -UseBasicParsing -TimeoutSec 300"

                            echo Extracting MASSTCLI to temporary location...
                            powershell -Command "$ProgressPreference = 'SilentlyContinue'; if (Test-Path 'C:\\temp\\masstcli_extract') { Remove-Item 'C:\\temp\\masstcli_extract' -Recurse -Force -ErrorAction SilentlyContinue }; New-Item -ItemType Directory -Path 'C:\\temp\\masstcli_extract' -Force | Out-Null; Expand-Archive -LiteralPath '%WORKSPACE%\\%MASST_ZIP%' -DestinationPath 'C:\\temp\\masstcli_extract' -Force"

                            echo Moving MASSTCLI to workspace...
                            powershell -Command "if (Test-Path '%WORKSPACE%\\tools\\MASSTCLI') { Remove-Item '%WORKSPACE%\\tools\\MASSTCLI' -Recurse -Force -ErrorAction SilentlyContinue }; Move-Item -Path 'C:\\temp\\masstcli_extract\\MASSTCLI-v1.1.0-windows-amd64' -Destination '%WORKSPACE%\\tools\\MASSTCLI' -Force"

                            echo Cleaning up temporary files...
                            powershell -Command "if (Test-Path 'C:\\temp\\masstcli_extract') { Remove-Item 'C:\\temp\\masstcli_extract' -Recurse -Force -ErrorAction SilentlyContinue }"

                        ) else (
                            echo MASSTCLI already exists, skipping download
                        )
                    '''
                }
            }
        }

        stage('Verify MASSTCLI Download') {
            steps {
                echo 'Verifying MASSTCLI installation...'
                bat '''
                    echo Verifying MASSTCLI executable...
                    if not exist "%MASST_DIR%\\MASSTCLI.exe" (
                        echo ERROR: MASSTCLI.exe not found at %MASST_DIR%!
                        echo Contents of tools directory:
                        dir /s /b "%WORKSPACE%\\tools"
                        exit /b 1
                    )

                    echo Running MASSTCLI version check...
                    "%MASST_DIR%\\MASSTCLI.exe" --version

                    echo.
                    echo ========================================
                    echo ✅ MASSTCLI downloaded and verified successfully
                    echo ========================================
                '''
            }
        }



//         stage('Analyze APK Files') {
//             steps {
//                 echo 'Scanning APK files...'
//                 script {
//                     bat '''
//                         set APK_FOUND=0
//                         for %%f in ("%ARTIFACTS_DIR%\\*.apk") do (
//                             if exist "%%f" (
//                                 set APK_FOUND=1
//                                 echo.
//                                 echo ========================================
//                                 echo Scanning APK: %%f
//                                 echo ========================================
//                                 "%MASST_DIR%\\MASSTCLI.exe" -input="%%f" -config="%CONFIG_FILE%" -v=true
//                                 if errorlevel 1 (
//                                     echo WARNING: Scan failed for %%f
//                                 )
//                             )
//                         )
//                         if %APK_FOUND%==0 (
//                             echo No APK files found in %ARTIFACTS_DIR%
//                         )
//                     '''
//                 }
//             }
//         }

//         stage('Analyze AAB Files') {
//             steps {
//                 echo 'Scanning AAB files...'
//                 script {
//                     bat '''
//                         set AAB_FOUND=0
//                         for %%f in ("%ARTIFACTS_DIR%\\*.aab") do (
//                             if exist "%%f" (
//                                 set AAB_FOUND=1
//                                 echo.
//                                 echo ========================================
//                                 echo Scanning AAB: %%f
//                                 echo ========================================
//                                 "%MASST_DIR%\\MASSTCLI.exe" -input="%%f" -config="%CONFIG_FILE%" -v=true
//                                 if errorlevel 1 (
//                                     echo WARNING: Scan failed for %%f
//                                 )
//                             )
//                         )
//                         if %AAB_FOUND%==0 (
//                             echo No AAB files found in %ARTIFACTS_DIR%
//                         )
//                     '''
//                 }
//             }
//         }
    }

    post {
        success {
            echo 'MASSTCLI pipeline completed successfully!'
        }
        failure {
            echo 'MASSTCLI pipeline failed. Please check the logs above.'
        }
//         always {
//             echo 'Cleaning up workspace...'
//             bat '''
//                 if exist "%WORKSPACE%\\%MASST_ZIP%" del "%WORKSPACE%\\%MASST_ZIP%"
//                 powershell -Command "if (Test-Path 'C:\\temp\\masstcli_extract') { Remove-Item 'C:\\temp\\masstcli_extract' -Recurse -Force -ErrorAction SilentlyContinue }"
//             '''
//         }
    }
}