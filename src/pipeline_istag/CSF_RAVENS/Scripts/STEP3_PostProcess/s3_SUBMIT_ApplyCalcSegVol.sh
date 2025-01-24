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
exe=${pwd}/ApplyCalcSegVol_SGEArray.sh

list=${prjDir}/Lists/${prjName}_QCFlags.csv
inDir=${prjDir}/Protocols/FAST
outDir=${prjDir}/Protocols/FAST

######################### 
######################### 
###  Main

mkdir -pv $outDir

#########################
### Make list of missing cases
echo "Making list of subjects to process ..."
tmplist=${outDir}/ListID_NotProcessed.csv
rm -rf $tmplist
for sub in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1
    inImg=${outDir}/${sub}/${sub}_T1_LPS_dlicv_seg.nii.gz    
    outCsv=${outDir}/${sub}/${sub}_T1_LPS_dlicv_seg_Vol.csv
    if [ -e $inImg ] && [ ! -e $outCsv ]; then
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
    FROM=1
    TO=`cat $tmplist | wc -l`

    mkdir -pv ${pwd}/sgelogs
    qsub -t ${FROM}-${TO} -j y -o ${pwd}/sgelogs/\$JOB_NAME-\$JOB_ID.log $exe $tmplist $inDir $outDir

fi

