#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov 20 14:11:17 2020

Filter SLURM's `sacct` output and display nicely.
Script can be run from local workstation (requires ssh login) or 
from cluster head node. For the second option prepare as follows:
        1. Copy script to location mounted to cluster head node (e.g. /Network/Cluster)
        2. In terminal ssh onto cluster headnode
        3. Activate Python with: `module add anaconda3/2020-07`

Example calls:
display help
    /path/to/sacctpy.py -h
display only own jobs from today:
    /path/to/sacctpy.py
display all jobs ran on the 2020-11-20:
    /path/to/sacctpy.py -a -s 2020-11-20 -e 2020-11-21
display all jobs ran on the 2020-11-20 with job name containing "hifi_diff":
    /path/to/sacctpy.py -a -s 2020-11-20 -e 2020-11-21 -n hifi_diff
display all jobs ran on the 2020-11-20 with job name containing "hifi_diff", excluding those being canceled:
    /path/to/sacctpy.py -a -s 2020-11-20 -e 2020-11-21 -n hifi_diff -x CANC

@author: bgesieri
"""

import argparse
from datetime import datetime, date, timedelta
import re, io
import numpy as np
import pandas as pd
from subprocess import run
import socket

def valid_date(s):
    try:
        return datetime.strptime(s, "%Y-%m-%d")
    except ValueError:
        try:
            return datetime.strptime(s, "%Y-%m-%dT%H:%M")
        except ValueError:
            msg = "Incorrect data format, should be YYYY-MM-DD or YYYY-MM-DDThh:mm"
            raise argparse.ArgumentTypeError(msg)


def iniPparser():
    parser = argparse.ArgumentParser(description="Filter SLURM sacct output and disply nicely")
    parser.add_argument("-s", 
                        "--starttime", 
                        help="The Start-time - format yyyy-mm-dd or yyyy-mm-ddThh:mm", 
                        type=valid_date, default=datetime.combine(date.today(), datetime.min.time()))
    parser.add_argument("-e", 
                        "--endtime",
                        help="The End-time - format yyyy-mm-dd or yyyy-mm-ddThh:mm", 
                        type=valid_date, default=datetime.now())
    parser.add_argument("-a","--all", help="display jobs for all user accounts",action="store_true",default=False)
    parser.add_argument("-n","--name", help="Regular expression, used to filter jobs containing this expression in their name",default="")
    parser.add_argument("-i","--include", help="Job states; Jobs with any of these states are displayed",default="")
    parser.add_argument("-x","--exclude", help="Job states; Jobs with any of these states will not be displayed",default="DUMMY")
    return parser


def filterSacct(pattern="", include="MEM|TIM|FAIL|COMP|PENDING|RUNNING", exlclude="DUMMY", allUser=""):

    # check if running on Cluster Headnode
    # print('Running on:',socket.gethostname())
    onHeadnode = re.search('isd28e87',socket.gethostname())!=None
    
    # prepare sacct command
    param='JobID,User,Account,JobName,Nodelist,AllocCPUS,AllocTres,MaxVMSize,MaxRSS,Start,Elapsed,State'
    cmd = 'sacct  -P ' + allUser + starttime + endtime + ' --format='+param+' --units=G'
    if not onHeadnode:
        cmd = 'ssh cluster.isd.med.uni-muenchen.de \'source /etc/profile; '+cmd+'\''
    
    # run sacct command
    temp = run(cmd, shell=True, capture_output=True)
    temp = temp.stdout.decode("utf-8")
    temp = io.StringIO(temp)
    dfSacct = pd.read_csv(temp, sep="|", dtype={'JobID': str})
    
    # filter JobIDs belonging to a particular Type of Job, characterized by JobName
    jobNameF = re.compile(pattern)
    incJobName = np.zeros(dfSacct.shape[0], dtype=bool)
    for j, jobName in enumerate(dfSacct.JobName):
        incJobName[j]= jobNameF.search(jobName) != None
    jobIDs = [re.sub('\..*','',temp) for temp in dfSacct.JobID[incJobName]]
    jobIDs = pd.unique(jobIDs)
    
    # filter by states
    incl = re.compile(include)
    excl = re.compile(exlclude)
    k=0
    for i, jobID in enumerate(jobIDs):
        # find all rows in dfSacct belonging to particular job
        idx = [re.match(re.escape(jobID)+'(\..*)?$',temp)!=None for temp in dfSacct.JobID ]
        dfT = dfSacct.iloc[idx,:]
        # check job state
        exclude = np.zeros(dfT.shape[0], dtype=bool)
        include = np.zeros(dfT.shape[0], dtype=bool)
        for j, state in enumerate(dfT.State):
            include[j]= incl.search(state) != None
            exclude[j]= excl.search(state) != None
        # print if job state is as desired
        if include.any() and not exclude.any():
            k+=1
            print('\n\n--[ %d. job ]--------------------------'%k)
            with pd.option_context('display.max_rows', None, 'display.max_columns', None, 'display.width', 250, 'display.max_colwidth', None): #, 'precision', 2):
                print(dfT.to_string(index=False))
                # print(dfT)
                # print(dfT[['JobID', 'User', 'Account', 'JobName', 'NodeList', 'Start', 'Elapsed', 'State']])
        
    print('\n')
    
    
    
    
# For running from the command line:
if __name__ == "__main__":
    parser = iniPparser()
    args = parser.parse_args()
    
    # print('\n')
    
    if args.endtime - args.starttime < timedelta():
        raise ValueError('The given endtime "{}" was before the starttime "{}"'.format(args.endtime,args.starttime))
    
    starttime=args.starttime.strftime("-S%Y-%m-%dT%H:%M ")
    if args.endtime==None:
        endtime=''
    else:
        endtime=args.endtime.strftime("-E%Y-%m-%dT%H:%M ")
    pattern=args.name
    if args.all:
        allUser='-a '
    else:
        allUser=""
        
    filterSacct(pattern, args.include, args.exclude, allUser)
    