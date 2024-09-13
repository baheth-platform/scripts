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
find "/media/ali-fadel/ieb_world/baheth/المحتوى/الدروس المفرغة/$name" -type f \( -name "config.json" -o -name "*.json" \) | xargs -I {} bash -c '
  file="{}"

  name="$2"
  repos_dir="$3"

  # Get the directory name (Parent folder).
  parent_dir=$(basename "$(dirname "$file")")

  # Get the base filename (With extension).
  file_name=$(basename "$file")

  # Get the directory structure relative to the source root.
  rel_path=$(dirname "$file" | sed "s|/media/ali-fadel/ieb_world/baheth/المحتوى/الدروس المفرغة/$name||")

  # Create the corresponding directory in the destination.
  mkdir -p "/media/ali-fadel/ieb_world/baheth-platform-github/${repos_dir}${rel_path}"

  # Check if the file is either config.json or if it matches the parent directory name.
  if [[ "$file_name" == "config.json" || "$file_name" == "$parent_dir.json" ]]; then
    # Copy the file to the destination
    cp "$file" "/media/ali-fadel/ieb_world/baheth-platform-github/${repos_dir}${rel_path}/"
  fi
' _ {} "$name" "$repos_dir"
