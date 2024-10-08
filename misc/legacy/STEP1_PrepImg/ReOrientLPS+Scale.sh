#!/bin/sh

set -x

inFile=$1
outDest=$2

inDest=`dirname $inFile`
inBase=`basename ${inFile%.nii.gz}`

cd $outDest 

### Copy input file, in case it is a softlink
cp -Lfv ${inFile} ${inBase}.nii.gz

### Get file pair
nifti1_test \
 -n2 ${inBase}.nii.gz \
 ${inBase}_temp;

### Resample/Reorient
3dresample \
 -orient rai \
 -prefix ${inBase}_temp_LPS.hdr \
 -inset ${inBase}_temp.hdr;

### Clear sform
nifti_tool \
 -mod_hdr \
 -mod_field sform_code 0 \
 -prefix ${inBase}_temp_LPS_nosform.hdr \
 -infiles ${inBase}_temp_LPS.hdr;

### Convert to nii.gz
nifti1_test \
 -zn1 \
 ${inBase}_temp_LPS_nosform.img \
 ${inBase}_LPS_notScaled;

min=$(3dBrickStat -slow -min ${inBase}_LPS_notScaled.nii.gz)
max=$(3dBrickStat -slow -max ${inBase}_LPS_notScaled.nii.gz)

3dcalc -a ${inBase}_LPS_notScaled.nii.gz -expr "((a-${min})/(${max}-${min}))*2048" -short -nscale -prefix ${inBase}_LPS.nii.gz
 
### Remove intermediate files
rm -fv ${inBase}_temp.{hdr,img} \
    ${inBase}_temp_LPS.{hdr,img} \
    ${inBase}_temp_LPS_nosform.{hdr,img} \
    ${inBase}_LPS_notScaled* \
    ${inBase}.nii.gz

set +x
