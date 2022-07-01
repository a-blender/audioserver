#!/bin/sh

# env vars

EXPORTED_DIR=./exported
PROCESSED_DIR=./processed

# create directories for exported wav files and processed mp3 files. For this script to work, save each 
# Ableton recording as a wav file in the 'exported' directory. This script watches that directory for new
# files, converts them to mp3 and loads them onto the server.

if [ ! -d "$EXPORTED_DIR" ]; then
	mkdir $EXPORTED_DIR
fi

if [ ! -d "$PROCESSED_DIR" ]; then
        mkdir $PROCESSED_DIR
fi

# check local arch type

if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux
	sudo apt-get install inotify-tools gzip
	if [ ! -d "$EXPORTED_DIR" ]; then
		mkdir $EXPORTED_DIR
	fi
	inotifywatch -v exported

elif [[ "$OSTYPE" == "darwin"* ]]; then
        # Mac OSX
	brew install fswatch
	brew install ffmpeg
	
	echo "Watching for new wav files..."

	fswatch -0 exported | while read -d "" event
  	do
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
  	done

fi
