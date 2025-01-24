#! /bin/bash +x

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
exe=${pwd}/ApplyDLICV_SingleImg_cpu_SGEArray.sh

list=${prjDir}/Lists/${prjName}_QCFlags.csv
inDir=${prjDir}/Protocols/ReOrientedLPS
outDir=${prjDir}/Protocols/DLICV

######################### 
###  Main

mkdir -pv $outDir

#########################
### Make list of missing cases
echo "Making list of subjects to process ..."
dlicvlist=${outDir}/ListID_NotProcessed.csv
rm -rf $dlicvlist
for sub in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1
    inImg=${inDir}/${sub}/${sub}_T1_LPS.nii.gz
    outImg=${outDir}/${sub}/${sub}_T1_LPS_dlicvmask.nii.gz
    outQCFail=${outDir}/${sub}/${sub}_QCFailFlag.txt
    if [ -e $inImg ] && [ ! -e $outImg ] && [ ! -e $outQCFail ]; then
        echo $sub >> ${dlicvlist}
    fi
done

if [ ! -e $dlicvlist ]; then
    numID=0
    echo "Process already completed for all subjects ..."
else	
    numID=`cat ${dlicvlist} | wc -l`
    echo "Will run for " $numID " subjects"
fi

#########################
### Run sge jobs

if [ "${numID}" -gt '0' ]; then
    FROM=1
    TO=`cat $dlicvlist | wc -l`

#    FROM=1
#    TO=4

    mkdir -pv ${pwd}/sgelogs
    qsub -t ${FROM}-${TO} -j y -o ${pwd}/sgelogs/\$JOB_NAME-\$JOB_ID.log -l h_vmem=32G -pe threaded 4 $exe $dlicvlist $inDir $outDir

#     cmd="$exe $dlicvlist $inDir $outDir "
#     echo $cmd
#     $cmd

fi
