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
exe=${pwd}/ReOrientLPS_SGEArray.sh

list=${prjDir}/Lists/${prjName}_QCFlags.csv
inDir=${prjDir}/Data/RenamedNifti
outDir=${prjDir}/Protocols/ReOrientedLPS

imgMod='T1'
#imgMod='T2'
#imgMod='FL'

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
    inImg=${inDir}/${sub}/${sub}_${imgMod}.nii.gz
    outImg=${outDir}/${sub}/${sub}_${imgMod}_LPS.nii.gz    
    if [ -e $inImg ] && [ ! -e $outImg ]; then
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

#    FROM=1
#    TO=14

    mkdir -pv ${pwd}/sgelogs
    qsub -t ${FROM}-${TO} -j y -o ${pwd}/sgelogs/\$JOB_NAME-\$JOB_ID.log $exe $tmplist $inDir $imgMod $outDir
fi
