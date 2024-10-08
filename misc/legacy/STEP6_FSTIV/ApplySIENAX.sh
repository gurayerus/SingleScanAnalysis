#! /bin/bash -x

sub=$1
t1=$2
odir=$3

export FSLOUTPUTTYPE='NIFTI_GZ'

mkdir -pv $odir

if [ -e $t1 ] && [ ! -e ${odir}/${sub}/${sub}_fastTIV.csv ] ; then
    
    mkdir -pv ${odir}/${sub}
    
    ## Apply samseg
    echo "Running: sienax"
#    cmd=(sienax ${t1} -o ${odir}/${sub} -d -B "-f 0.35 -B")
#    "${cmd[@]}"
    sienax ${t1} -o ${odir}/${sub} -d -B '-f 0.35 -B'

#     ## Calc sbTIV
#     echo "Running sbTIV calc"
#     sbTIV=`cat ${odir}/${sub}/sbtiv.stats | cut -d, -f2 | sed 's/ //g'`
#     echo ${sub},${sbTIV} > ${odir}/${sub}/${sub}_fastTIV.csv
#     
#     ## Convert out seg to nifti
#     mri_convert ${odir}/${sub}/seg.mgz ${odir}/${sub}/${sub}_SAMSEG.nii.gz
#     
#     ## Remove FS images
#     rm -rf ${odir}/${sub}/*.mgz
fi
