#!/usr/bin/env bash

set -o errexit

# Define global variables from configuration file.
# Supports setting variables from environment.
source autojob.conf

export AJ_WORKDIR=${AJ_WORKDIR:-$workdir}
export AJ_PROJECTS=${AJ_PROJECTS:-$projects}
export AJ_JOBS=${AJ_JOBS:-$jobs}
export AJ_WORKSPACES=${AJ_WORKSPACES:-$workspaces}
export AJ_LOCKS=${AJ_LOCKS:-$locks}
export AJ_LOGS=${AJ_LOGS:-$logs}

function main {
  # Ensure the necessary directories are all here.
  # This might get removed if I ever get to packaging Autojob properly.
  mkdir -p ${AJ_PROJECTS}
  mkdir -p ${AJ_JOBS}
  mkdir -p ${AJ_WORKSPACES}
  mkdir -p ${AJ_LOCKS}
  mkdir -p ${AJ_LOGS}

  # TODO: Implement logging for launcher.
  # logfile=${AJ_LOGS}/autojob.log

  # If ls finds no matches, it exits with error anyway,
  # so no reason to check manually.
  jobs_conf=$( ls ${AJ_JOBS}/*.conf )

  # For every job config file found, start an executor.
  # Run in a subshell to prevent variable polution between jobs.
  for job in ${jobs_conf}; do
    (
      source ${job}

      # If the job has no UUID, generate one
      if [[ ! ${uuid} ]]; then
        uuid=$( uuidgen )
        echo uuid="${uuid}" >> "${job}"
      fi

      job_logfile=${AJ_LOGS}/${uuid}.log

      # Check if instance of a job is already running.
      if [[ ! -f ${AJ_LOCKS}/${uuid} ]]; then
        echo date > ${AJ_LOCKS}/${uuid}
        # TODO: Support running jobs in containers
        sh  ${AJ_WORKDIR}/executor.sh ${job} &>> ${job_logfile} &
      fi
    )
  done
}

# Interpreted language blues
main
