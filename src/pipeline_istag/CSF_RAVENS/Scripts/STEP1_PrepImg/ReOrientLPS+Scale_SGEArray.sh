#!/bin/sh

#### This script should be run as an array job!!!
#### It runs the processing for a single subject in the list
#### ${SGE_TASK_ID} is set by the qsub command with the array job parameters
#### It indicates the line number read from the input list (input subject ID)
####
#### Note   : first create a list of IDs for which out image is missing so 
####          that this will not run an sge job unnecessarily for these IDs

exedir='/cbica/projects/OASIS/OASIS3/Pipelines/OASIS3_DLICV_2022/Scripts/STEP1_PrepImg'
scr=${exedir}/ReOrientLPS+Scale.sh

## Input args
list=$1
inDir=$2
imgMod=$3
outDir=$4

echo '--------------------------------------------------'
echo "Running: $0 $1 $2 $3 $4"
echo '--------------------------------------------------'

## Check input
if [ -z $list ]; then
    echo "Usage: $0 [ListOfIDs] [InImgDir] [ImgModality] [OutImgDir]"
    exit;
fi

## Get subject from list
SUB=`awk NR==${SGE_TASK_ID} $list | cut -d, -f1`

echo "Running for subject: $SUB"

## Make output folder
mkdir -pv ${outDir}/${SUB}/sgelogs

## Run script
inImg=${inDir}/${SUB}/${SUB}_${imgMod}.nii.gz
outImg=${outDir}/${SUB}/${SUB}_${imgMod}_LPS.nii.gz    
if [ -e $inImg ]; then
    ${scr} $inImg ${outDir}/${SUB} > ${outDir}/${SUB}/sgelogs/ReOrientLPS+Scale.sh-${JOB_ID}-${SGE_TASK_ID}.log 2>&1;
fi
    
