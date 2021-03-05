# ISD HPC CLuster

## Overview

The HPC (High Performance Computing) cluster is a central computation infrastructure at ISD. Using the SLURM cluster engine (same as on the LRZ cluster), you can run jobs, i.e. simple commands, scripts or arrays, on the CPU cluster (GPUs coming soon). For training of neural networks, there will be a dedicated training node with 2 large memory GPUs (coming soon).

## User Documentation

**Here you can find the user documentation including [wiki](http://git.isd-muc.de:8080/DueringLab/Cluster_User/wiki) and code examples.

> **Please note**: The documentation is **work in progress** and will be extended over the coming weeks. More detailed SLURM documentations are available elsewhere, e.g. at the [Leibniz Rechenzentrum](https://doku.lrz.de/display/PUBLIC/SLURM+Workload+Manager). Most aspects will also apply to our cluster.

> **Always keep in mind:** For a smooth operation of the cluster, it is important that you **specify the correct resource requirements** of your jobs. If you specify your resources too high, your jobs might block the cluster and unnecessarily delay jobs of other users.
    
## Cluster Hardware

The Linux-based cluster consists of a head node (or "login node", the entry point for users) and compute nodes. The configuration of the nodes is as follows:

|  | Head Node | Compute Nodes |
| ---- | --------- | ---- |
| Machines | 1 | 9 |
| CPU(s) | AMD EPYC "Rome" 7302P (16-Core) | 2x AMD EPYC "Rome" 7352 (24-Core)|
| Physical cores | 0 | 48 per node, 384 in total |
| RAM | 128 GB | 256 GB per node |
| Local scratch | 0 | 1 TB NVMe-SSD |
| Networking | 10 Gbit | 10 Gbit |
| GPUs | - | NVidia Quadro RTX 5000 (16 GB), 5 nodes<br>2x NVidia Quadro RTX 6000 (24 GB), 1 node# |

The shared cluster storage is located on the "Bigfoot" Storage system.  
One node (#) will be equipped with two large memory GPUs can be used for training of neural networks.

## Software 

The operating system of the cluster is Ubuntu Linux 18.04.3 LTS. There is only command-line access, no graphical user interface.

Software is handled via [environment modules](https://modules.readthedocs.io/en/latest/). Please contact the cluster admins to install software cluster-wide.

## Administrators

To get more info or a cluster user account, please contact the cluster admins:  
[Benno](mailto:benno.gesierich@med.uni-muenchen.de) or 
[Marco](mailto:marco.duering@med.uni-muenchen.de)

&nbsp;