#! /bin/bash -x

scid=$1
inImg=$2
outPref=$3

outImg1=${outPref}_DS222.nii.gz

if [ -e $inImg ] && [ ! -e $outImg1 ]; then
    cmd="3dresample -dxyz 2 2 2 -rmode Cu -prefix $outImg1 -inset $inImg"
    echo "About to run: $cmd"
    $cmd
fi

for k in 4 8; do
    outImg2=${outImg1%.nii.gz}_s${k}.nii.gz
    if [ -e $outImg1 ] && [ ! -e $outImg2 ]; then
            cmd="3dmerge -1blur_fwhm $k -prefix $outImg2 $outImg1"
            echo "About to run: $cmd"
            $cmd
    fi
done
