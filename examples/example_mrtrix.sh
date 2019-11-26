#!/bin/bash
#SBATCH -c 24
#SBATCH --mem=10G
#SBATCH -t 0-03:00


# ---------------------------------------------------------------------------------
# EXAMPLE PIPELINE FOR TYPICAL MRTRIX PIPELINE
#
# The subject ID is handed over via argument 1
# Usage: sbatch example_mrtrix.sh <SUBJECT_ID>
#
# Resources: With the SBATCH lines above, this job will use 
# 24 CPUs (= 12 physical cores) and 10 GB of total RAM.
# The walltime is set to 3 hours. If the job does not finish within this time
# something is wrong and we will free up cluster resources
#
# You can redirect stdout and stderr to custom files, e.g. to your home folder
# Usage: sbatch --output=~/out.txt --error=~/error.txt example_mrtrix.sh <SUBJECT_ID>
#
# Example loop for submitting list of subjects:
# t=$(date "+%Y-%m-%d")
# for s in sub-01 sub-02 sub-03;do
# sbatch --output=~/${s}_${t}.out --error=~/${s}_${t}.err example_mrtrix.sh ${s}
# done
#
# Tip: You can also use a job array to submit multiple subjects (not covered here)
# ---------------------------------------------------------------------------------


# Unload all environment modules and load needed modules
module purge
module load fsl/6.0.2
module load ants/2.3.2
module load mrtrix3/RC3_latest-24

# First argument as subject ID
id=$1

# Data folder (JUST AN EXAMPLE!)
dfolder=/cluster/mduering/CVC/${id}

# Use local scratch dir (best practice for high I/O jobs)
export LOCAL_SCRATCH_DIR=/scratch/${USER}/${SLURM_JOB_ID}
mkdir -p "${LOCAL_SCRATCH_DIR}"
cd "${LOCAL_SCRATCH_DIR}" || { echo "Error with local scratch directory creation. Aborting"; exit 1; }

# Copy data to scratch
mrconvert ${dfolder}/DIFF/${id}_dwi-data.nii.gz dwi.mif -fslgrad ${dfolder}/DIFF/eddy/${id}_dwi.bvecold ${dfolder}/DIFF/${id}_dwi.bval -datatype float32 -stride 0,0,0,1  2>&1
cp ${dfolder}/T1w/${id}_T1w.nii.gz .
maskfilter ${dfolder}/DIFF/${id}_dwi-mask.nii.gz erode mask.mif -npass 1  2>&1

# Register T1 to DWI using ANTS
dwiextract dwi.mif - -bzero | mrmath - mean meanb0.nii.gz -axis 3  2>&1
antsRegistrationSyN.sh -d 3 -f meanb0.nii.gz -m ${id}_T1w.nii.gz -o t1_to_dwi -t r -p f -n 24
antsApplyTransforms -d 3 -e 3 -i ${id}_T1w.nii.gz -r ${id}_T1w.nii.gz -t t1_to_dwi0GenericAffine.mat -o t1_to_dwi.nii.gz --float

# Create 5TT image
5ttgen fsl t1_to_dwi.nii.gz 5tt.mif -nthreads 24 2>&1
5tt2vis 5tt.mif 5tt_vis.mif  2>&1

# Response function estimation
dwi2response -nthreads=24 dhollander dwi.mif wm_response.txt gm_response.txt csf_response.txt 2>&1

# FOD calculation
dwi2fod -nthreads 24 msmt_csd -mask mask.mif dwi.mif wm_response.txt wmfod.mif gm_response.txt gm.mif csf_response.txt csf.mif 2>&1
mrconvert -coord 3 0 wmfod.mif - | mrcat csf.mif gm.mif - vf.mif  2>&1

# Multi-tissue informed log-domain intensity normalisation
mtnormalise -nthreads 24 wmfod.mif wmfod_norm.mif gm.mif gm_norm.mif csf.mif csf_norm.mif -mask mask.mif 2>&1 

# Tractography
tckgen -nthreads 24 wmfod_norm.mif 1M.tck -act 5tt.mif -backtrack -crop_at_gmwmi -seed_dynamic wmfod_norm.mif -maxlength 250 -select 1M -cutoff 0.06 2>&1 

# SIFT2 filtering
tcksift2 -nthreads 24 1M.tck wmfod_norm.mif sift2_weights.txt -act 5tt.mif 2>&1

# Copy results
cp *.mif ${dfolder}/
cp *.tck ${dfolder}/
cp *.gz  ${dfolder}/
cp *.txt ${dfolder}/

# Remove local scratch folder
rm -rf "${LOCAL_SCRATCH_DIR}"
exit 0
