#! /bin/bash -x

sub=$1
t1=$2
odir=$3

export FSLOUTPUTTYPE='NIFTI_GZ'
export SUBJECTS_DIR=$odir

mkdir -pv $odir

module unload freesurfer/5.3.0
module load freesurfer/7.2.0

if [ -e $t1 ] && [ ! -e ${odir}/${sub}/${sub}_FS_sbTIV.csv ] ; then
    
    mkdir -pv ${odir}/${sub}
    
    ## Apply samseg
    echo "Running: samseg"
    run_samseg --input ${t1} --output ${odir}/${sub} --threads 4

    ## Calc sbTIV
    echo "Running sbTIV calc"
    sbTIV=`cat ${odir}/${sub}/sbtiv.stats | cut -d, -f2 | sed 's/ //g'`
    echo ${sub},${sbTIV} > ${odir}/${sub}/${sub}_FS_sbTIV.csv
    
    ## Convert out seg to nifti
    mri_convert ${odir}/${sub}/seg.mgz ${odir}/${sub}/${sub}_SAMSEG.nii.gz
    
    ## Remove FS images
    rm -rf ${odir}/${sub}/*.mgz
fi
