Jobs have very simple configurations. The only variables
as of now are $name and $url. The former is a pretty name for the job,
and the latter is a URL to a git repository.

A third field, $uuid, is generated automatically. You will never have
to specify this manually, although it is written to the configuration file.

The job config file is also sourced at the beginning of the executor.
This means that you could overwrite variables for a specific log.
For example, you could set $AJ_WORKSPACES to a tmpfs.
