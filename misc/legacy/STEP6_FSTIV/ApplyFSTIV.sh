#! /bin/bash -x

sub=$1
t1=$2
odir=$3

export FSLOUTPUTTYPE='NIFTI_GZ'

mkdir -pv $odir

module unload freesurfer/5.3.0
module load freesurfer/7.2.0

if [ -e $t1 ] && [ ! -e ${odir}/${sub}/${sub}_FS_eTIV.csv ] ; then
    
    ## Apply the first 5 steps of FS
    echo "Running: recon-all -s $sub -i $t1 -sd $odir -autorecon1"
    recon-all -s $sub -i $t1 -sd $odir -autorecon1

    ## Calc eTIV
    echo "Running eTIV calc"
    export SUBJECTS_DIR=$odir

    eTIV=`mri_segstats --subject $sub --etiv-only | grep eTIV | awk '{ print $4 }'`
    echo ${sub},${eTIV} > ${odir}/${sub}/${sub}_FS_eTIV.csv

    ## Convert out bmask to nifti
    mri_convert ${odir}/${sub}/mri/brainmask.mgz ${odir}/${sub}/${sub}_fsbmask.nii.gz
    
    ## Remove FS images
    rm -rf ${odir}/${sub}/mri
fi
