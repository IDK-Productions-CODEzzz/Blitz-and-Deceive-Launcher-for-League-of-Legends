@echo off
setlocal enabledelayedexpansion


:: CODE EXECUTION

call :CheckFileName
call :GetFiles
call :HandleFilesAndDeceive
call :CheckBlitz
call :StartAllPrograms
exit


:: FUNCTIONS

:: Check if file was renamed; rename back to original and rerun if so
:CheckFileName
    set file_name=League of Legends w Deceive and Blitz.bat
    if not "%file_name%"=="%~nx0" (
        rename "%~nx0" "%file_name%"
        echo It was detected that this file was renamed. Please refrain from renaming this file in the future.
        echo.
        echo.
        pause
        start "" "%cd%\%file_name%"
        exit
    )
    exit /b

:: Get all files' names in current directory and count; should be 2
:GetFiles
    set counter=0
    for %%f in (*.*) do (
        set files[!counter!]=%%f
        set /a counter=!counter!+1
    )
    set /a counter=%counter%-1
    exit /b

:: Handle the files as needed dependent on count
:: Purpose is to ensure "League of Legends w Deceive and Blitz.bat" and "Deceive.exe" are the only programs.
:HandleFilesAndDeceive
    :: 1 file; need to download Deceive
    :: NOTE: Counter is used for referencing arrays; starts at 0 not 1
    if %counter%==0 (
        :DownloadDeceive
        echo Deceive not found. Downloading Deceive.
        echo.
        echo.
        curl -O -L "https://github.com/molenzwiebel/Deceive/releases/latest/download/Deceive.exe"
        exit /b
    )
    :: More than 1 file; try to find Deceive and handle if cannot find
    set deceive_found=0
    for /L %%i in (0,1,%counter%) do (
        if "!files[%%i]!"=="Deceive.exe" (
            set deceive_found=1
        ) else if not "!files[%%i]!"=="%file_name%" (
            del "!files[%%i]!"
        )
    )
    :: If Deceive not found, download it; else continue
    if not %deceive_found%==1 (
        goto :DownloadDeceive
    )
    exit /b

:: Check if Blitz is installed
:: Blitz seems to give the user no choice where to be installed; only needlessly advanced users would have trouble here
:CheckBlitz
    if not exist "%localappdata%\Programs\Blitz\Blitz.exe" (
        call :InstallBlitz
    )
    exit /b

:: Download and install Blitz; surprisingly tricky with how the URL redirects
:InstallBlitz
    for /f "tokens=4 delims=/ " %%A in ('curl -L -I "https://blitz.gg/download/win" 2^>nul ^| findstr /i "^location:"') do (
        set blitz_name=%%A
    )
    echo Blitz not found. Downloading Blitz.
    echo.
    echo.
    curl -L "https://blitz.gg/download/win" --output "%cd%\%blitz_name%"
    echo.
    echo.
    echo Installing Blitz. Install file will be removed once installation is done...
    start /wait "" "%cd%\%blitz_name%"
    del "%cd%\%blitz_name%"
    exit /b

:: Start League of Legends, Blitz, and Deceive
:: Note Deceive starts League of Legends itself
:StartAllPrograms
    start "" "%cd%\Deceive.exe"
    start "" "%localappdata%\Programs\Blitz\Blitz.exe"
    exit /b