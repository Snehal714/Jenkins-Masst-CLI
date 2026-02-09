pipeline {
    agent any

    environment {
        MASST_DIR = "tools\\MASSTCLI"
        ARTIFACTS_DIR = "artifacts"
        CONFIG_FILE = "config.bm"
        MASST_ZIP = "MASSTCLI.zip"
        MASST_EXTRACTED = "MASSTCLI-v1.1.0-windows-amd64"
        MASST_URL = "https://storage.googleapis.com/masst-assets/Defender-Binary-Integrator/1.0.0/Windows/MASSTCLI-v1.1.0-windows-amd64.zip"
    }

    stages {

        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Prepare Tools Directory') {
            steps {
                bat '''
                if not exist tools mkdir tools
                '''
            }
        }

        stage('Download & Setup MASSTCLI') {
            steps {
                bat '''
                REM Cleanup old MASSTCLI safely
                if exist "%MASST_DIR%" (
                    echo Removing existing MASSTCLI directory
                    rmdir /s /q "%MASST_DIR%"
                )

                REM Download ZIP
                echo Downloading MASSTCLI...
                powershell -Command "curl.exe -L \\"%MASST_URL%\\" -o \\"%MASST_ZIP%\\""

                REM Extract ZIP
                echo Extracting MASSTCLI...
                powershell -Command "Expand-Archive -Force \\"%MASST_ZIP%\\" \\"tools\\""

                REM Rename extracted folder
                if exist "tools\\%MASST_EXTRACTED%" (
                    ren "tools\\%MASST_EXTRACTED%" "MASSTCLI"
                )
                '''
            }
        }

        stage('Verify MASSTCLI') {
            steps {
                bat '''
                if not exist "%MASST_DIR%\\MASSTCLI.exe" (
                    echo MASSTCLI executable not found
                    exit /b 1
                ) else (
                    echo MASSTCLI verified successfully
                )
                '''
            }
        }

        stage('Analyze APK') {
            steps {
                bat '''
                if exist "%ARTIFACTS_DIR%\\*.apk" (
                    for %%f in ("%ARTIFACTS_DIR%\\*.apk") do (
                        echo Scanning %%f
                        "%MASST_DIR%\\MASSTCLI.exe" -input="%%f" -config="%CONFIG_FILE%" -v=true
                    )
                ) else (
                    echo No APK files found
                )
                '''
            }
        }

        stage('Analyze AAB') {
            steps {
                bat '''
                if exist "%ARTIFACTS_DIR%\\*.aab" (
                    for %%f in ("%ARTIFACTS_DIR%\\*.aab") do (
                        echo Scanning %%f
                        "%MASST_DIR%\\MASSTCLI.exe" -input="%%f" -config="%CONFIG_FILE%" -v=true
                    )
                ) else (
                    echo No AAB files found
                )
                '''
            }
        }
    }

    post {
        always {
            echo 'MASSTCLI pipeline finished'
        }
    }
}
