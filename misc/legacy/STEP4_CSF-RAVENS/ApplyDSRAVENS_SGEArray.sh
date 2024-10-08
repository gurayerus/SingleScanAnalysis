#!/bin/sh

#### This script should be run as an array job!!!
#### It runs the processing for a single subject in the list
#### ${SGE_TASK_ID} is set by the qsub command with the array job parameters
#### It indicates the line number read from the input list (input subject ID)

exedir='/cbica/projects/ADNI/Pipelines/ADNI_DLICV_2022/Scripts/STEP4_CSF-RAVENS'
scr=${exedir}/ApplyDSRAVENS.sh

## Input args
list=$1
indir=$2
outdir=$3

echo '--------------------------------------------------'
echo "Running: $0 $1 $2 $3"
echo '--------------------------------------------------'

## Check input
if [ -z $list ]; then
    echo "Usage: $0 [ListOfIDs] [InDir] [OutDir]"
    exit;
fi

## Get subject from list
SUB=`awk NR==${SGE_TASK_ID} $list | cut -d, -f1`
# SUB='JHU001001_19960425'

echo "Running for subject: $SUB"

## Make output folder
mkdir -pv ${outdir}/${SUB}/sgelogs

## Run script
inImg=${indir}/${SUB}/${SUB}_T1_LPS_dlicv_seg_ants-0.3_RAVENS_1.nii.gz
outPref=${outdir}/${SUB}/${SUB}_T1_LPS_dlicv_seg_ants-0.3_RAVENS_1

${scr} $SUB $inImg $outPref > ${outdir}/${SUB}/sgelogs/ApplyDSRAVENS.sh-${JOB_ID}-${SGE_TASK_ID}.log 2>&1;

# ${scr} $SUB $inImg $outPref 
    
