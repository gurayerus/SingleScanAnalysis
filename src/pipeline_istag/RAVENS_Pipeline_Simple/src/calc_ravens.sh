#!/bin/bash

export FSLOUTPUTTYPE=NIFTI_GZ

# Get the current directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

templ=`realpath ../templates/colin27_t1_tal_lin.nii.gz`

mrid=$1
in=$2
out=$3

if [ -z $1 ] || [ -z $2 ] || [ -z $3 ]; then
    echo Usage: $0 {mrid} {indir} {outdir}
    exit 0
fi

mkdir -pv $out
indir=`realpath $in`
outdir=`realpath $out`

# FAST segmentation
t1=${indir}/${mrid}/${mrid}_T1_LPS_dlicv.nii.gz
mkdir -pv ${outdir}/fast/${mrid}
seg_pref=${outdir}/fast/${mrid}/${mrid}_T1_LPS_dlicv_fast
seg_img=${seg_pref}_seg.nii.gz

if [ -e $seg_img ]; then
    echo "Out seg img exists, skip: $seg_img"
else
    fast --nopve -o $seg_pref -v $t1
fi

# RAVENS calculation
method='ants'
p_scale='1000'
p_reg=0.3
mkdir -pv ${outdir}/ravens/${mrid}
out_warp=${outdir}/ravens/${mrid}/${mrid}_T1_LPS_dlicv_warpedto_${templ}

if [ -e ${out_warp}.nii.gz ]; then
    echo "Out seg img exists, skip: ${out_warp}.nii.gz"
else
    ${SCRIPT_DIR}/utils/GenerateRAVENS.sh -s $t1 -t $templ -o ${out_warp} -l ${seg_img} -p $p_reg -i 2 -f $p_scale -m $method
fi
