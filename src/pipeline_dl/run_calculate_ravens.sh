#! /bin/bash

mrid='Img1'
in_img=`realpath ../../test/input/Img1_T1_LPS.nii.gz`
templ_img=`realpath ../../test/input/Img2_T1_LPS.nii.gz`
out_dir=`realpath ../../test/out_ravens`

mkdir -pv $out_dir

cmd="./calculate_ravens.sh -s $mrid -i $in_img -t $templ_img -o $out_dir"
echo "About to run $cmd"
$cmd
