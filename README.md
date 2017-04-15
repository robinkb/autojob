# Autojob

A very simple job executor that pulls a git repository,
and runs an Autofile script contained in the repo. This might remind you of
how Jenkins pipelines work.

The `run.sh` script makes sure that the directory structure is present.
Then, it reads the job configuration files under `jobs/`, and launches
a `job.sh` script for every job that it finds.

These jobs will pull the specified git repository.
If the master branch has changed, the job executor will pull the changes,
and run the Autofile script contained in the repository. If the repository
is not already present under the `projects` directory, it will pull the
repository and run the Autofile script.
