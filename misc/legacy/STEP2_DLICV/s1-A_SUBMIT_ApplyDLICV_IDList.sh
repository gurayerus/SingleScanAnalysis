#! /bin/bash

############################################################
### Project specific variables
###
### the assumption is that after setting these variables
### the rest of the scripts will run without need to
### edit anything else
###
prjName='ADNI'
prjDir='/cbica/projects/ADNI/Pipelines/ADNI_DLICV_2022'
############################################################

######################### 
###  Other variables
pwd=`pwd`
exe=${pwd}/ApplyDLICV_IDList_cpu.sh

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
echo "ID,T1,DLICV" > $dlicvlist

#for sub in `sed 1d $list | cut -d, -f1`; do
for sub in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1

    inImg=${inDir}/${sub}/${sub}_T1_LPS.nii.gz
    outImg=${outDir}/${sub}/${sub}_T1_LPS_dlicvmask.nii.gz    
    if [ -e $inImg ] && [ ! -e $outImg ]; then
        echo $sub,$inImg,$outImg >> ${dlicvlist}
    fi
done

numID=`cat ${dlicvlist} | wc -l`
echo "Will run for " $(( numID - 1 )) " subjects"


mkdir -pv ${pwd}/sgelogs

qsub -j y -o ${pwd}/sgelogs/\$JOB_NAME-\$JOB_ID.log -l h_vmem=32G -pe threaded 4 $exe $dlicvlist $inDir $outDir 

# cmd="$exe $dlicvlist $inDir $outDir "
# echo $cmd
# $cmd
