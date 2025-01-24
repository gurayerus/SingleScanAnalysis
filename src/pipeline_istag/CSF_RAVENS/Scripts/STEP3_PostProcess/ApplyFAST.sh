#! /bin/bash +x

export FSLOUTPUTTYPE=NIFTI_GZ

sub=$1
t1=$2
odir=$3

t1s=${odir}/${sub}_T1_LPS_dlicv_seg.nii.gz
if [ -e $t1 ] && [ ! -e $t1s ]; then
    fast --nopve -o ${t1s%_seg.nii.gz}.nii.gz -v $t1
fi
    
