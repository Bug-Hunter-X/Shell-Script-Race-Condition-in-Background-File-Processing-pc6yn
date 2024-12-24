#!/bin/bash

# This script attempts to process a list of files,
# but it has a subtle race condition.

files=("file1.txt" "file2.txt" "file3.txt")

for file in "${files[@]}"; do
  # Problem: Using a simple background process without proper synchronization
  process_file "$file" &
  # The next iteration starts before the previous one finishes
done

wait # Wait for all background processes to complete

process_file() {
  echo "Processing file: $1"
  sleep 1 # Simulate some work
  # Simulate occasional file error.
  if [[ "$1" == "file2.txt" ]]; then
    touch "$1.lock"
    sleep 2
    rm "$1.lock"
  fi
  echo "Finished processing file: $1"
}
