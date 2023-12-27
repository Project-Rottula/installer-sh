@echo off

REM Store current working directory
set "workingPath=%cd%"

REM Create Rottula folder
if exist "%workingPath%\Rottula" (
    set /p "choice= Rottula folder already exists. Do you want to overwrite it? [y/n]: "
    if /I "%choice%"=="Y" (
        rmdir /s /q "%workingPath%\Rottula"
        mkdir Rottula
    ) else (
        echo Aborting.
        exit /b 1
    )
) else (
    echo Creating Rottula folder
    mkdir Rottula
)

REM Check latest version at /latest route
for /f %%i in ('curl -s http://192.168.1.3:7000/latest ^| tr -d "\""') do set "latest_version=%%i"

echo Latest version is %latest_version%

REM Check if version can be downloaded by checking 200 OK
for /f %%i in ('curl -s -o nul -w "%%{http_code}" "http://192.168.1.3:7000/version/%latest_version%"') do set "http_code=%%i"

if %http_code% equ 200 (
    echo Downloading version %latest_version%
    REM check if client, cache and media zip files exists and ask if user wants to overwrite them
    REM Download zip files
    REM Add code here to handle checking and downloading zip files

    REM Unzip client and cache
    echo Unzipping client.zip
    REM Add code here to unzip client.zip and cache.zip to Rottula folder

    REM Remember path to Cache folder
    set "cache_path=%workingPath%\Rottula\Cache"

    REM Unzip media to Rottula\Client\Contents\Java\media
    echo Unzipping media.zip
    REM Add code here to unzip media.zip to Rottula\Client\Contents\Java\ folder

    REM Edit run.bat and debug.bat
    REM Add code here to edit run.bat and debug.bat

    echo Removing old run.bat and debug.bat
    if exist "%workingPath%\Rottula\Client\run.bat" (
        del "%workingPath%\Rottula\Client\run.bat"
    )

    if exist "%workingPath%\Rottula\Client\debug.bat" (
        del "%workingPath%\Rottula\Client\debug.bat"
    )

    REM Create run.bat and debug.bat
    REM Run %workingPath%\Rottula\Client\MacOS\JavaAppLauncher -cachedir=%cache_path%
    REM Debug %workingPath%\Rottula\Client\MacOS\JavaAppLauncher -cachedir=%cache_path% -debug
    echo %workingPath%\Rottula\Client\Contents\MacOS\JavaAppLauncher -cachedir=%cache_path% >> "%workingPath%\Rottula\Client\run.bat"
    echo %workingPath%\Rottula\Client\Contents\MacOS\JavaAppLauncher -cachedir=%cache_path% -debug >> "%workingPath%\Rottula\Client\debug.bat"

    echo Use command: "chmod +x %workingPath%\Rottula\Client\run.bat" and "chmod +x %workingPath%\Rottula\Client\debug.bat" to make them executable.
    echo Setup completed successfully.
) else (
    echo Version cannot be downloaded.
)

