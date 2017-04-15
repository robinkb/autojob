#!/usr/bin/env bash

set -o errexit

WORK_DIR=$PWD
PROJECTS_DIR=$WORK_DIR/projects
JOBS_DIR=$WORK_DIR/jobs
RUN_DIR=$WORK_DIR/run
WORKSPACES_DIR=$WORK_DIR/workspaces

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
    echo UUID="$UUID" >> $CONF
  fi

  echo "Running job $NAME"
  sh $WORK_DIR/job.sh $job
done
