#!/usr/bin/env bash

set -o errexit

source ./common_vars

# Ensure the necessary directories are all here.
mkdir -p $PROJECTS_DIR
mkdir -p $JOBS_DIR
mkdir -p $RUN_DIR
mkdir -p $WORKSPACES_DIR

JOBS=$(ls $JOBS_DIR/*.conf)

if [ ! $JOBS ]; then
  echo "No jobs found! Exiting..."
  exit 0
fi

for job in $JOBS; do
  source $job

  # If the job has no UUID, generate one
  if [ ! $UUID ]; then
    UUID=$(uuidgen)
    echo UUID="$UUID" >> $job
  fi

  # TODO: Support running jobs in containers
  echo "Running job $NAME"
  sh $WORK_DIR/job.sh $job
done
