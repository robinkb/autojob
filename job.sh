#!/usr/bin/env bash

set -o errexit

source $1

WORK_DIR=$PWD
PROJECTS_DIR=$WORK_DIR/projects
JOBS_DIR=$WORK_DIR/jobs
RUN_DIR=$WORK_DIR/run
WORKSPACES_DIR=$WORK_DIR/workspaces

trap 'cleanup' EXIT

function cleanup {
  if [ $UUID ]; then
    echo "Releasing lock..."
    rm $RUN_DIR/$UUID

    echo "Cleaning workspace..."
    # Make sure that we don't ever accidentally erase the workspace dir/
    cd $WORKSPACES_DIR
    rm -rf $UUID
  fi
}

if [ -f $RUN_DIR/$UUID ]; then
  echo "This job is already running! Exiting..."
  exit 1
else
  touch $RUN_DIR/$UUID
fi

RUN=false

PROJECT=$(echo $URL | cut -d / -f 4)
REPO=$(echo $URL | cut -d / -f 5)

# If the project directory does not exist, create it.
# We include the project name to prevent naming conflicts.
if [ ! -d $PROJECTS_DIR/$PROJECT ]; then
  mkdir -p $PROJECTS_DIR/$PROJECT
fi

# If the repo does not yet exist locally, clone it.
# In this case, the current run is probably the first,
# and we should run the job.
if [ ! -d $PROJECTS_DIR/$PROJECT/$REPO ]; then
  git clone $URL $PROJECTS_DIR/$PROJECT/$REPO
  RUN=true
fi

# Change working directory into the repository.
cd $PROJECTS_DIR/$PROJECT/$REPO

# We can skip these steps if the job is set to run already.
if ! $RUN; then
  # Fetch references from remote repository.
  git fetch

  # If the repo is behind, run the job.
  # TODO: Account for jobs failing.
  if git status -uno | grep -q behind; then
    RUN=true
  fi
fi

# Create the workspace, copy the git repo,
# and run the job.
if $RUN; then
  git pull

  mkdir $WORKSPACES_DIR/$UUID
  cd $WORKSPACES_DIR/$UUID
  rsync -a --exclude='$PROJECTS_DIR/$PROJECT/$REPO/.git' \
    $PROJECTS_DIR/$PROJECT/$REPO/* .

  sh Autofile
fi
