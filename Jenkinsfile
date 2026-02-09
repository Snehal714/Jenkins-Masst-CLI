pipeline {
    agent any

    environment {
        MASST_DIR = "tools\\MASSTCLI"
        ARTIFACTS_DIR = "artifacts"
        CONFIG_FILE = "config.bm"
        MASST_ZIP = "MASSTCLI.zip"
//         MASST_URL = "https://example.com/MASSTCLI.zip"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Download MASSTCLI') {
            steps {
                bat '''
                if not exist tools mkdir tools

                if not exist %MASST_DIR% (
                    echo Downloading MASSTCLI using curl...
                    powershell -Command "curl -L \"https://storage.googleapis.com/masst-assets/Defender-Binary-Integrator/1.0.0/MacOS/MASSTCLI-v1.1.0-darwin-arm64.zip\" -o \"MASSTCLI.zip\""
                    powershell -Command "Expand-Archive -Force \"MASSTCLI.zip\" tools"
                ) else (
                    echo MASSTCLI already exists
                )
                '''
            }
        }

        stage('Verify MASSTCLI') {
            steps {
                bat '''
                if not exist %MASST_DIR%\\MASSTCLI.exe (
                    echo MASSTCLI executable not found
                    exit /b 1
                )
                '''
            }
        }

        stage('Analyze APK') {
            steps {
                bat '''
                if exist %ARTIFACTS_DIR%\\*.apk (
                    for %%f in (%ARTIFACTS_DIR%\\*.apk) do (
                        echo Scanning %%f
                        %MASST_DIR%\\MASSTCLI.exe ^
                          -input="%%f" ^
                          -config="%CONFIG_FILE%" ^
                          -v=true
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
                if exist %ARTIFACTS_DIR%\\*.aab (
                    for %%f in (%ARTIFACTS_DIR%\\*.aab) do (
                        echo Scanning %%f
                        %MASST_DIR%\\MASSTCLI.exe ^
                          -input="%%f" ^
                          -config="%CONFIG_FILE%" ^
                          -v=true
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
