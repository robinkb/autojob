#!/usr/bin/env bash

# The executor assumes that it is clear to run.
# Any checks to ensure this should be performed in the launcher script.

set -o errexit
#set -x

trap 'cleanup' EXIT

# Load the job configuration file.
source $1

function main {
  # TODO: Make project/repo retrieval more robust.
  project=$(echo ${url} | cut -d / -f 4)
  repo=$(echo ${url} | cut -d / -f 5)
  repo_path=${AJ_PROJECTS}/${project}/${repo}

  message_start

  # If the repo does not yet exist locally, clone it.
  # Include the project name to prevent naming conflicts.
  if [[ ! -d ${repo_path} ]]; then
    echo "Cloning repository from ${url}"
    mkdir -p ${repo_path}

    git clone ${url} ${repo_path}
    execute
  else
    cd ${repo_path}

    # Fetch references from remote repository.
    git fetch

    # If the repo is behind, run the job.
    # TODO: Account for jobs failing?
    if git status -uno | grep -q behind; then
      echo "Updates found! Pulling repository..."
      git pull
      execute
    else
      echo "No updates found."
    fi
  fi

  message_exit
}

# Prepares the workspace and executes the job
function execute {
  echo "Preparing workspace..."
  mkdir ${AJ_WORKSPACES}/${uuid}
  cd ${AJ_WORKSPACES}/${uuid}

  # Copy the git repo into the workspace, except the git data.
  # rsync is a git dependency, so it's always present.
  rsync -a --exclude='${repo_path}/.git' ${repo_path}/* .

  echo "Executing Autofile..."
  sh Autofile
}

function message_start {
  cat << EOF

================
Executor started
Time: $(date)

EOF
}

function message_exit {
  cat << EOF

Executor exiting
Time: $(date)
================

EOF
}

# Clean up the lockfile and workspace when the executor exits.
function cleanup {
  if [[ ${uuid} ]]; then
    echo "Releasing lock..."
    rm ${AJ_LOCKS}/${uuid}

    echo "Cleaning workspace..."
    # Make sure that we don't ever accidentally erase the workspace dir/
    cd ${AJ_WORKSPACES}
    rm -rf ${uuid}
  fi
}

# Interpreted language blues
main
