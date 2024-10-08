#!/bin/sh

### Default paths
MODELS=/cbica/home/erusg/doshijim_files/TensorFlow/LifeSpanData_FinalModels/Models
CONTAINER=/cbica/home/erusg/doshijim_files/Singularity/deepmrseg/deepmrseg_1.0.0.Alpha2.sif

### Get File Attributes
FileAtt()
{
        FileAttIP=$1;

        FileAttdir="$(cd "$(dirname "$FileAttIP")" && pwd -P)"
        FileAttext=${FileAttIP##*.}
        FileAttbName=`basename ${FileAttIP%.${FileAttext}}`

        if [ "$FileAttext" == "gz" ]
        then
                FileAttext=${FileAttbName##*.}.${FileAttext}
                FileAttbName=`basename ${FileAttIP%.${FileAttext}}`
        fi

        if [ "$FileAttext" != "nii.gz" ] && [ "$FileAttext" != "hdr" ] && [ "$FileAttext" != "img" ] && [ "$FileAttext" != "nii" ]
        then
                echo -e "\nERROR: Input file extension $FileAttext not recognized! Please check ..."
                cleanUpandExit
        fi

        echo $FileAttext $FileAttbName $FileAttdir
}

### Timestamps
startTime=`date +%F-%H:%M:%S`
startTimeStamp=`date +%s`

echo -e "\nHostname   : `hostname`"
echo -e "Start time : ${startTime}\n"

### Read args
inList=$1
inDir=$2
outDir=$3

### Get FileAtt
if [ ! -e "$inList" ]; then
    echo -e "\nERROR: Input list $inList does not exist! Aborting operations ..."
    exit 1
fi

### Create dest dir
mkdir -pv $outDir

# Run DLICV model
echo -e "\n\nRunning DLICV model...\n"
set -x
singularity \
    run \
    -B ${TMPDIR} \
    -B ${inDir} \
    -B ${outDir} \
    ${CONTAINER} \
    deepmrseg_test \
    --mdlDir ${MODELS}/DLICV/Final/LPS/ \
    --mdlDir ${MODELS}/DLICV/Final/PSL/ \
    --mdlDir ${MODELS}/DLICV/Final/SLP/ \
    --sList $inList \
    --nJobs 4;
set +x

### Execution time
endTimeStamp=`date +%s`;
echo -e "\n\nExecution time:  `echo "scale=2; ( ${endTimeStamp} - ${startTimeStamp} ) / 60" | bc` mins"
