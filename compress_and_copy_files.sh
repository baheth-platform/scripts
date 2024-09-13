#!/bin/bash

# Assign arguments to variables.
name="$1"
repos_dir="$2"

# Check if both arguments are provided.
if [ -z "$name" ] || [ -z "$repos_dir" ]; then
  echo "Usage: $0 \"name\" \"repos_dir\""
  exit 1
fi

# Start processing files.
find "/media/ali-fadel/ieb_world/baheth/المحتوى/الدروس المفرغة/$name" -type f -name "*.m4a" | xargs -I {} -P 12 bash -c '
  file="{}"

  name="$2"
  repos_dir="$3"

  # Get the base filename without extension.
  base=$(basename "$file" .m4a)

  # Get the directory structure relative to the source root.
  rel_path=$(dirname "$file" | sed "s|/media/ali-fadel/ieb_world/baheth/المحتوى/الدروس المفرغة/$name||")

  # Create the corresponding directory in the destination.
  mkdir -p "/media/ali-fadel/ieb_world/baheth-platform-github/${repos_dir}${rel_path}"

  # Set the output path for the converted file.
  output="/media/ali-fadel/ieb_world/baheth-platform-github/${repos_dir}${rel_path}/${base}.webm"

  # Run ffmpeg to convert the m4a file to webm.
  ffmpeg -i "$file" -c:a libopus -b:a 28k "$output"
' _ {} "$name" "$repos_dir"
