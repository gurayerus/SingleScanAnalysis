#!/bin/sh -x

#### This script should be run as an array job!!!
#### It runs the processing for a single subject in the list
#### ${SGE_TASK_ID} is set by the qsub command with the array job parameters
#### It indicates the line number read from the input list (input subject ID)
####
#### Note   : first create a list of IDs for which out image is missing so 
####          that this will not run an sge job unnecessarily for these IDs

exedir='/cbica/projects/ADNI/Pipelines/ADNI_DLICV_2022/Scripts/STEP2_DLICV'
scr=${exedir}/ApplyDLICV_SingleImg_cpu.sh

## Input args
list=$1
inDir=$2
outDir=$3

## Check input
if [ -z $list ]; then
    echo "Usage: $0 [ListOfIDs] [InImgDir] [OutImgDir]"
    exit;
fi

## Get subject from list
#SUB=`awk NR==${SGE_TASK_ID} $list | cut -d, -f1`

SUB='TBIAD241FAN_20150903'

echo "Running for subject: $SUB"

## Make output folder
mkdir -pv ${outDir}/${SUB}/sgelogs

## Run script
inImg=${inDir}/${SUB}/${SUB}_T1_LPS.nii.gz
outSub=${outDir}/${SUB}
mkdir -pv $outSub
outImg=${outSub}/${SUB}_T1_LPS_dlicvmask.nii.gz

if [ -e $inImg ] && [ ! -e $outImg ]; then
#     ${scr} $inDir $inImg $outSub $outImg > ${outSub}/sgelogs/ApplyDLICV_SingleImg_cpu.sh-${JOB_ID}-${SGE_TASK_ID}.log 2>&1;
echo  ${scr} $inDir $inImg $outSub $outImg
fi
