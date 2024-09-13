#!/bin/bash

# Assign arguments to variables.
speaker="$1"

# Check if the speaker name is provided.
if [ -z "$speaker" ]; then
  echo "Usage: $0 \"speaker_name\""
  exit 1
fi

# Loop through each directory in the current directory.
for dir in */; do
  # Remove trailing slash from directory name.
  repo_name="${dir%/}"

  # JSON file inside the directory.
  json_file="$repo_name/$repo_name.json"

  # Extract the "title" attribute from the JSON file.
  if [ -f "$json_file" ]; then
    title=$(jq -r '.title' "$json_file")
    echo "Title found: $title"

    description="$speaker | $title"

    # Ensure the description is at most 160 characters.
    if [ ${#description} -gt 160 ]; then
      description="${description:0:160}"  # Truncate to 160 characters.
      echo "Truncated description to: $description"
    fi
  else
    echo "No JSON file found for $repo_name, skipping..."
    continue
  fi

  # Check if the GitHub repository already exists.
  gh repo view "baheth-platform/$repo_name" &> /dev/null

  cd "$repo_name" || exit

  if [ $? -ne 0 ]; then
    # Create a new GitHub repository with the directory name and the title as the description.
    echo "Creating GitHub repository: $repo_name with description: $title"
    gh repo create "$repo_name" --public --description "$description" --homepage "https://baheth.ieasybooks.com/playlist?list=$repo_name"

    git init
    git branch -M main
    git remote add origin "git@github.com:baheth-platform/$repo_name.git"
  else
    echo "Repository $repo_name already exists, skipping creation."
  fi

  git config user.name "baheth-platform"
  git config user.email "baheth.platform@gmail.com"

  # Add files in batches of 10 and push after each batch commit
  total_files=$(git ls-files -o --exclude-standard | wc -l)
  batch_size=10
  processed=0

  # Loop through the files, adding and committing them in batches
  while [ $processed -lt $total_files ]; do
    files_to_add=$(git ls-files -o --exclude-standard | head -n $batch_size)

    if [ -n "$files_to_add" ]; then
      git add -- $files_to_add
      git commit -m "Add batch of files" --author "baheth-platform <baheth.platform@gmail.com>"
      git push -u origin main
      processed=$((processed + batch_size))
      echo "Committed and pushed batch of files."
    fi
  done

  cd ..

  echo "Finished processing $repo_name!"
done
