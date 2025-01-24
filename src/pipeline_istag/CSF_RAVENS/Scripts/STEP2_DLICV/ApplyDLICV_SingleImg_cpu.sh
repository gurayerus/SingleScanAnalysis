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
inDir=$1
inImg=$2
outDir=$3
outImg=$4

if [ ! -e "$inImg" ]; then
        echo -e "\nERROR: Input file $inImg does not exist! Aborting operations ..."
        exit 1
fi

# Run DLICV model
if [ ! -e ${outImg} ]; then

    echo -e "\n\nRunning DLICV model...\n"
    set -x
    singularity \
    run \
    -B ${MODELS} \
    -B ${TMPDIR} \
    -B ${inDir} \
    -B ${outDir} \
    ${CONTAINER} \
    deepmrseg_test \
    --mdlDir ${MODELS}/DLICV/Final/LPS/ \
    --mdlDir ${MODELS}/DLICV/Final/PSL/ \
    --mdlDir ${MODELS}/DLICV/Final/SLP/ \
    --inImg $inImg \
    --outImg ${outImg} \
    --nJobs 4;
    set +x

else
    echo -e "\nWARNING: Out img exists! Skip step: ${outImg}"
fi

### Execution time
endTimeStamp=`date +%s`;
echo -e "\n\nExecution time:  `echo "scale=2; ( ${endTimeStamp} - ${startTimeStamp} ) / 60" | bc` mins"
