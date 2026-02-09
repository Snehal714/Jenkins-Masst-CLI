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
                checkout scm
            }
        }

        stage('Prepare Tools Directory') {
            steps {
                bat '''
                REM Create tools folder if it doesn't exist
                if not exist tools mkdir tools
                '''
            }
        }

        stage('Download MASSTCLI') {
            steps {
                bat '''
                REM Download MASSTCLI zip only if it doesn't exist
                if not exist "%MASST_DIR%" (
                    echo Downloading MASSTCLI using curl.exe...
                    powershell -Command "curl.exe -L \\"%MASST_URL%\\" -o \\"%WORKSPACE%\\\\%MASST_ZIP%\\""

                    echo Extracting MASSTCLI...
                    powershell -Command "Expand-Archive -Force -LiteralPath \\"%WORKSPACE%\\\\%MASST_ZIP%\\" -DestinationPath \\"%WORKSPACE%\\\\tools\\""
                ) else (
                    echo MASSTCLI already exists
                )
                '''
            }
        }

        stage('Verify MASSTCLI') {
            steps {
                bat '''
                REM Verify MASSTCLI executable exists
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
                REM Scan APK files
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
                REM Scan AAB files
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
