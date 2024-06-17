#!/bin/bash

# Fixing crap is a pain in linux, especially with filenames

# Log file
touch /var/log/filename_fix.log # Make sure it's there
log_file="/var/log/filename_fix.log"

echo "Logging to '/var/log/filename_fix.log'...."

sanitize_filename() {
  echo "Normalizing MP3 Filename" >> "$log_file"
  for file in *.mp3; do
        # Extract the base name of the file
        base_name=$(basename "$file")
        # Replace special characters with underscores
        filename="${base_name//[^a-zA-Z0-9._-]/_}"
        echo "Normalized MP3 Filename to: ${filename}" >> "$log_file"
        mv -n "$file" "$filename"
   done
   echo "Files removed of bad chars..."
}

# Function to rename files
rename_files() {
    echo "Starting renaming process..." | tee -a $log_file
    for file in *.mp3; do
        # Check if file exists
        if [ -e "$file" ]; then
            # Replace multiple underscores with a single one
            temp_file=$(echo $file | tr '_' ' ')
            # Replace underscore with space if it is before or after a hyphen
            temp_file2=$(echo $temp_file | sed 's/-_/- /g' | sed 's/_-/- /g')
            # Replace leading underscore with a space
            temp_file3=$(echo $temp_file2 | sed 's/^_//')
            # Ensure each '-' has a leading and trailing space unless it's next to a number
            temp_file4=$(echo $temp_file3 | sed -r 's/([^0-9 ])-/\1 -/g')
            temp_file5=$(echo $temp_file4 | sed -r 's/-([^0-9 ])/- \1/g')
            # Replace '- -' with '-'
            temp_file6=$(echo $temp_file5 | sed 's/- -/-/g')
            # Fix the placement of a '-' before the file extension
            temp_file7=$(echo $temp_file6 | sed 's/- ././g')
            # Remove leading and trailing spaces
            new_file=$(echo $temp_file7 | xargs)
            # Rename the file
            mv -n "$file" "$new_file"
            # Log the change
            echo "Renamed $file to $new_file" | tee -a $log_file
        else
            echo "File $file does not exist" | tee -a $log_file
        fi
    done
    echo "Renaming process completed." | tee -a $log_file
}

# Function to perform sanity check to remove any multiple spaces left over in the filename
sanity_check() {
    echo "Starting sanity check..." | tee -a $log_file
    for file in *.mp3; do
        # Check if file exists
        if [ -e "$file" ]; then
            # Replace multiple spaces with a single one
            new_file=$(echo $file | tr -s ' ')
            # Rename the file
            mv -n "$file" "$new_file"
            # Log the change
            echo "Sanity check: Renamed $file to $new_file" | tee -a $log_file
        else
            echo "File $file does not exist" | tee -a $log_file
        fi
    done
    echo "Sanity check completed." | tee -a $log_file
}

# Call the functions
sanitize_filename
rename_files
sanity_check
