#!/bin/sh -x

#### This script should be run as an array job!!!
#### It runs the processing for a single subject in the list
#### ${SGE_TASK_ID} is set by the qsub command with the array job parameters
#### It indicates the line number read from the input list (input subject ID)
####
#### Note   : first create a list of IDs for which out image is missing so 
####          that this will not run an sge job unnecessarily for these IDs

exedir='/cbica/projects/ADNI/Pipelines/ADNI_DLICV_2022/Scripts/STEP4_CSF-RAVENS'
scr=${exedir}/ApplyCSFRAVENS.sh

## Input args
list=$1
t1Dir=$2
segDir=$3
outDir=$4

echo '--------------------------------------------------'
echo "Running: $0 $1 $2 $3 $4"
echo '--------------------------------------------------'

## Check input
if [ -z $list ]; then
    echo "Usage: $0 [ListOfIDs] [T1Dir] [SegDir] [OutDir]"
    exit;
fi

## Get subject from list
SUB=`awk NR==${SGE_TASK_ID} $list | cut -d, -f1`
# SUB='JHU001001_19980429'

echo "Running for subject: $SUB"

## Make output folder
mkdir -pv ${outDir}/${SUB}/sgelogs

## Run script
t1img=${t1Dir}/${SUB}/${SUB}_T1_LPS_dlicv.nii.gz
t1seg=${segDir}/${SUB}/${SUB}_T1_LPS_dlicv_seg.nii.gz

${scr} $SUB $t1img $t1seg ${outDir}/${SUB} > ${outDir}/${SUB}/sgelogs/ApplyCSFRAVENS.sh-${JOB_ID}-${SGE_TASK_ID}.log 2>&1;

# ${scr} $SUB $t1img $t1seg ${outDir}/${SUB}


    
