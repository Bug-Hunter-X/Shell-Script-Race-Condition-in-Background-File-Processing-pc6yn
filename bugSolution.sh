#!/bin/bash

# This script addresses the race condition by using a semaphore
# to ensure that only one file is processed at a time.

files=("file1.txt" "file2.txt" "file3.txt")
sem=my_semaphore

# Create semaphore with value 1 (allows 1 concurrent process)
sem_init

for file in "${files[@]}"; do
  # Acquire the semaphore
  sem_wait "$sem"
  # Process the file
  process_file "$file"
  # Release the semaphore
  sem_post "$sem"
done

sem_unlink "$sem" # Cleanup semaphore

process_file() {
  echo "Processing file: $1"
  sleep 1 # Simulate some work
  # Simulate occasional file error
  if [[ "$1" == "file2.txt" ]]; then
    touch "$1.lock"
    sleep 2
    rm "$1.lock"
  fi
  echo "Finished processing file: $1"
}

sem_init() {
  if ! semget -n 1 -t 1 -x -c 1 "$sem"; then
    echo "semaphore not created "
  fi
}

sem_wait() {
  semop "$sem" -1
}

sem_post() {
  semop "$sem" 1
}
