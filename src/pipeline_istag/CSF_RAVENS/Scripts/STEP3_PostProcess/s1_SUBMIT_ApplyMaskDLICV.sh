#! /bin/bash +x

export FSLOUTPUTTYPE=NIFTI_GZ

############################################################
### Project specific variables
###
### the assumption is that after setting these variables
### the rest of the scripts will run without need to
### edit anything else
###
prjName='OASIS3'
prjDir='/cbica/projects/OASIS/OASIS3/Pipelines/OASIS3_DLICV_2022'
############################################################

######################### 
###  Other variables
pwd=`pwd`
exe=${pwd}/ApplyMaskDLICV.sh

list=${prjDir}/Lists/${prjName}_QCFlags.csv
inDir=${prjDir}/Protocols/ReOrientedLPS
maskDir=${prjDir}/Protocols/DLICV
outDir=${prjDir}/Protocols/DLICV

######################### 
######################### 
###  Main

mkdir -pv $outDir

#########################
### Make list of missing cases
echo "Making list of subjects to process ..."
tmplist=${outDir}/ListID_NotProcessed_maskDLICV.csv
rm -rf $tmplist
for sub in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1
    inImg1=${inDir}/${sub}/${sub}_T1_LPS.nii.gz
    inImg2=${maskDir}/${sub}/${sub}_T1_LPS_dlicvmask.nii.gz
    outImg=${outDir}/${sub}/${sub}_T1_LPS_dlicv.nii.gz
    if [ -e $inImg1 ] && [ -e $inImg2 ] && [ ! -e $outImg ]; then
        echo $sub >> ${tmplist}
    fi
done

if [ ! -e $tmplist ]; then
    numID=0
    echo "Process already completed for all subjects ..."
else	
    numID=`cat ${tmplist} | wc -l`
    echo "Will run for " $numID " subjects"
fi

#########################
### Run sge jobs

if [ "${numID}" -gt '0' ]; then

    mkdir -pv ${pwd}/sgelogs
    qsub -j y -o ${pwd}/sgelogs/\$JOB_NAME-\$JOB_ID.log $exe $tmplist $inDir $maskDir $outDir

fi
