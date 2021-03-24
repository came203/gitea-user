#!/bin/bash
#SBATCH --output=PATH/TO/JOBNAME_HERE-%A_%a.out
#SBATCH --cpus-per-task=24
#SBATCH --time=0-01:00
#SBATCH --mem=10G


# ---------------------------------------------------------------------------------------
# EXAMPLE FOR A JOB ARRAY
#
# An array is run several times, while in each run, the variable $SLURM_ARRAY_TASK_ID
# assumes the number of a specified index value.
#
# Submit the array.sh script with: `sbatch --array=<INDEX VALUES> array.sh`
# Index values can be specified in several ways, e.g. 1-10 or 1,2,6,7
#
# Example for an array where $SLURM_ARRAY_TASK_ID will go through values from 1 to 10:
# sbatch --array=1-10 array.sh
#
# The number of array tasks allowed to run simultaniously can be limited using the %N suffix,
# where N is the number of active tasks. The following example would throttle a job array 
# with 100 tasks by keeping only 5 tasks active at a time:
# sbatch --array=1-100%5 array.sh
#
# If you want to change the number of simultaneous tasks of an active job, you can use scontrol:
# `scontrol update ArrayTaskThrottle=<count> JobId=<jobID>`
# e.g. `scontrol update ArrayTaskThrottle=50 JobId=12345`
#
# In the #SBATCH lines above, %A is the job ID, %a is the index value
#
# As always, options can be used at the command line with sbatch or in an SBATCH line.
# This also applies to --array=, which can be included above as SBATCH --array=...
#
# Resource specifications in the SBATCH lines are just examples!
# ---------------------------------------------------------------------------------------


# EXAMPLE 1
#
# Load a list of commands and submit lines as jobs according to index numbers
command=$(sed -n "$SLURM_ARRAY_TASK_ID"p /PATH/TO/commands.txt)
$command


# EXAMPLE 2
#
# Go through a list of values, e.g. subject-IDs and pass them to a script according to index numbers
subject=$(sed -n "$SLURM_ARRAY_TASK_ID"p /PATH/TO/subjects.txt)
/PATH/TO/SCRIPT_TO_RUN $subject


