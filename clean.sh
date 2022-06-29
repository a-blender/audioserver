#!/bin/bash

Clean the exported directory of non-wav files, and the processed directory of non-mp3 files.

EXPORTED_FILES=$(find ./exported -type f ! -name "*wav")
PROCESSED_FILES=$(find ./processed -type f ! -name "*mp3")

echo "Cleaning song files..."

for file in $EXPORTED_FILES
do
	echo "Removing $file from exported files"
	rm -f $file
done

for file in $PROCESSED_FILES
do
	echo "Removing $file from processed files"
	rm -f $file
done
echo "Done!"
