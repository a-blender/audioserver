#!/bin/bash

# For this script to work, save each Ableton recording as a wav file in the EXPORTED directory. This script
# watches that directory for new files, converts them to mp3 and loads them onto an HTTPS server for direct
# streaming

# Env vars

EXPORTED_DIR=./exported
PROCESSED_DIR=./processed

# Docker image script to process wav files

# This script will be run inside the container and is platform independent so no need to check the
# system arch and use different packages based on the OS. This makes the script smaller, portable,
# and more efficient.

# Create dirs for EXPORTED wav files and PROCESSED mp3 files. The EXPORTED dir stores new recorded 
# files and the PROCESSED dir stores recordings converted to mp3

if [ ! -d "$EXPORTED_DIR" ]; then
	mkdir $EXPORTED_DIR
fi

if [ ! -d "$PROCESSED_DIR" ]; then
    mkdir $PROCESSED_DIR
fi

# Watch for new files in EXPORTED and when they show up
# 1. Convert to mp3
# 2. Copy to the server

while true
do
	echo "Watching for new wav files..."

	fswatch -0 exported -1 | while read -d "" event
	do	
	if [ ! "$(ls $EXPORTED_DIR)" ]; then
		echo "Action noticed but no new files found"
	fi

	if [ "$(ls $EXPORTED_DIR)" ]; then
		# on new ${event}, convert all exported wav files to mp3 so they can be externally hosted
		# store new mp3s in the 'processed' directory
		for file in $EXPORTED_DIR/*
		do
		# never overwrite	
		ffmpeg -i $file processed/$(basename $file .wav).mp3 -n
		done 	

    	# copy mp3 files to the server
		echo "Copying converted mp3 files to the server..."
		cp -r processed/* songs
		echo "Done!" 
	fi
	done
done
