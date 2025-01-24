#!/bin/sh

#### This script should be run as an array job!!!
#### It runs the processing for a single subject in the list
#### ${SGE_TASK_ID} is set by the qsub command with the array job parameters
#### It indicates the line number read from the input list (input subject ID)

export FSLOUTPUTTYPE=NIFTI_GZ

pdir=/cbica/projects/OASIS/OASIS3/Pipelines/OASIS3_DLICV_2022
exedir="${pdir}/Scripts/STEP3_PostProcess"
scr=${exedir}/ApplyFAST.sh

## Input args
list=$1
imgDir=$2
outDir=$3

## Check input
if [ -z $list ]; then
    echo "Usage: $0 [ListOfIDs] [inImgDir] [MaskDir] [OutDir]"
    exit;
fi

## Get subject from list
SUB=`awk NR==${SGE_TASK_ID} $list | cut -d, -f1`

echo "Running for subject: $SUB"

## Make output folder
mkdir -pv ${outDir}/${SUB}/sgelogs

## Run script
inImg=${imgDir}/${SUB}/${SUB}_T1_LPS_dlicv.nii.gz

${scr} $SUB $inImg ${outDir}/${SUB} > ${outDir}/${SUB}/sgelogs/ApplyFAST.sh-${JOB_ID}-${SGE_TASK_ID}.log 2>&1;

