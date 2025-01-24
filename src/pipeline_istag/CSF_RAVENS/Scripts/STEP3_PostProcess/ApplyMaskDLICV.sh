#! /bin/bash -x

export FSLOUTPUTTYPE=NIFTI_GZ

list=$1
indir=$2
maskdir=$3
outdir=$4

for ll in `cut -d, -f1 $list`; do
    osub=${outdir}/$ll
    mkdir -pv $osub

    inImg=${indir}/${ll}/${ll}_T1_LPS.nii.gz
    inMask=${maskdir}/${ll}/${ll}_T1_LPS_dlicvmask.nii.gz
    outImg=${outdir}/${ll}/${ll}_T1_LPS_dlicv.nii.gz
    
    if [ -e $inImg ] && [ -e $inMask ] && [ ! -e $outImg ]; then
        3dcalc -prefix $outImg -a $inImg -b $inMask -expr "a*step(b)" -verbose -nscale
    fi
    
done    
