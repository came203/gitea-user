| [User Documentation](http://git.isd-muc.de:8080/DueringLab/Cluster_User/wiki) | [Dashboard](http://cluster.isd.med.uni-muenchen.de/dashboard.html) | [Detailed Dashboard](http://cluster.isd.med.uni-muenchen.de/dashboard2.html) | [Gitea](http://git.isd-muc.de) |
| --- | --- | --- | --- |

## Overview

The HPC (High Performance Computing) cluster is a central computation infrastructure at ISD. Using the SLURM cluster engine (same as on the LRZ cluster), you can run jobs, i.e. simple commands, scripts or arrays, on the CPU + GPU cluster. For training of neural networks, one node is equipped with 2 large memory GPUs.

## User Documentation

**Please consult the user documentation including [wiki](http://git.isd-muc.de:8080/DueringLab/Cluster_User/wiki) and [example code](http://git.isd-muc.de:8080/DueringLab/Cluster_User).**  
The documentation is found on the Gitea server (login with your **FUL account**).

> **Please note**: The documentation is **work in progress** and will be extended over the coming weeks. More detailed SLURM documentations are available elsewhere, e.g. at the [Leibniz Rechenzentrum](https://doku.lrz.de/display/PUBLIC/SLURM+Workload+Manager). Most aspects will also apply to our cluster.

> **Always keep in mind:** For a smooth operation of the cluster, it is important that you **specify the correct resource requirements** of your jobs. If you specify your resources too high, your jobs might block the cluster and unnecessarily delay jobs of other users.
    
## Cluster Hardware

The Linux-based cluster consists of a head node (or "login node", the entry point for users) and compute nodes. The configuration of the nodes is as follows:

|  | Head Node | Compute Nodes |
| ---- | --------- | ---- |
| Machines | 1 | 9 |
| CPU(s) | AMD EPYC 16-Core (7302P) | 2x AMD EPYC 24-Core (7352 or 7402)|
| Physical cores | None for compute | 48 per node, 432 in total |
| RAM | 128 GB | 256 GB per node |
| Local scratch | 0 | 1 TB NVMe-SSD |
| Networking | 10 Gbit | 10 Gbit |
| GPUs | - | NVidia Quadro RTX 5000 (16 GB), 5 nodes<br>2x NVidia Quadro RTX 6000 (24 GB), 1 node# |

The shared cluster storage is located on the "Bigfoot" Storage system.  
One node (#) is equipped with two large memory GPUs and can be used for training of neural networks.

## Software 

The operating system of the cluster is Ubuntu Linux 18.04.4 LTS (HWE). There is only command-line access, no complete graphical user interface.

Software is mostly handled via [environment modules](https://modules.readthedocs.io/en/latest/) or Singularity containers. You can install your own binaries and use your own containers. Please contact the cluster admins to install more complex packages or to deploy software cluster-wide.

## Administrators

To get more info or a cluster user account, please contact [ISD IT](edvb@isd-muenchen.de).

&nbsp;