#!/bin/bash

# Store current working directory
workingPath=$(pwd)

# Create Rottula folder
if [ -d "$workingPath/Rottula" ]; then
    read -p "Rottula folder already exists. Do you want to overwrite it? [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$workingPath/Rottula"
        mkdir Rottula
    else
        echo "Aborting."
        exit 1
    fi
else
    echo "Creating Rottula folder"
    mkdir Rottula
fi

# Check latest version at /latest route
latest_version=$(curl -s http://192.168.1.3:7000/latest | tr -d '"')

echo "Latest version is $latest_version"

# Check if version can be downloaded by checking 200 OK
http_code=$(curl -s -o /dev/null -w "%{http_code}" "http://192.168.1.3:7000/version/$latest_version")

if [ $http_code -eq 200 ]; then
    echo "Downloading version $latest_version"
    # check if client, cache and media zip files exists and ask if user wants to overwrite them
    # Download zip files
    #
    if [ -f "$workingPath/client.zip" ]; then
        read -p "client.zip already exists. Do you want to overwrite it? [y/n] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for part in client cache media; do
                echo "Downloading $part.zip"
                curl -o "$part.zip" "http://192.168.1.3:7000/version/$latest_version/$part"
            done
        else
            echo "Using old data"
        fi
    fi
    # Unzip client and cache
    echo "Unzipping client.zip"
    unzip client.zip -d Rottula

    echo "Unzipping cache.zip"
    unzip cache.zip -d Rottula

    # Remember path to Cache folder
    cache_path="$workingPath/Rottula/Cache"

    # Unzip media to Rottula/Client/Contents/Java/media
    echo "Unzipping media.zip"
    unzip media.zip -d Rottula/Client/Contents/Java/

    # Edit run.sh and debug.sh
    # sed -i '' "s|way_to_launcher|$workingPath/Rottula/Client/MacOS/JavaAppLauncher -cachedir=$cache_path -debug|g" Rottula/Client/run.sh
    # sed -i '' "s|Cache_folder_path|$cache_path|g" Rottula/Client/run.sh
    #
    # check if debug.sh and run.sh exists remove if yes
    echo "Removing old run.sh and debug.sh"
    if [ -f "$workingPath/Rottula/Client/run.sh" ]; then
        rm "$workingPath/Rottula/Client/run.sh"
    fi

    if [ -f "$workingPath/Rottula/Client/debug.sh" ]; then
        rm "$workingPath/Rottula/Client/debug.sh"
    fi

    # Create run.sh and debug.sh
    # Run ./Rottula/Client/MacOS/JavaAppLauncher -cachedir=/Users/admin/Documents/Rottula/Cache
    # Debug ./Rottula/Client/MacOS/JavaAppLauncher -cachedir=/Users/admin/Documents/Rottula/Cache -debug
    echo "$workingPath/Rottula/Client/Contents/MacOS/JavaAppLauncher -cachedir=$cache_path" >> "$workingPath/Rottula/Client/run.sh"
    echo "$workingPath/Rottula/Client/Contents/MacOS/JavaAppLauncher -cachedir=$cache_path -debug" >> "$workingPath/Rottula/Client/debug.sh"

    echo "Use command: \"chmod +x $workingPath/Rottula/Client/run.sh\" and \"chmod +x $workingPath/Rottula/Client/debug.sh\" to make them executable."
    echo "Setup completed successfully."
else
    echo "Version cannot be downloaded."
fi
