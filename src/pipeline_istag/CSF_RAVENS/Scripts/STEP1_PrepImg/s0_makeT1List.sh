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
list=${prjDir}/Lists/${prjName}_MasterList.csv

inDir=${prjDir}/Data/RenamedNifti

outCsv=${list%.csv}_WithT1.csv
outQC=${prjDir}/Lists/${prjName}_QCFlags.csv

######################### 
######################### 
###  Main

#########################
### Make list of existing scans
i=1
echo "Making list of scans ..."
if [ ! -e $outCsv ]; then
    echo SCID > $outCsv
    echo SCID,QCFail,QCDesc,Notes > $outQC
    for sub in `sed 1d $list | cut -d, -f1`; do
        echo "Sub $i : $sub"
        inImg=${inDir}/${sub}/${sub}_T1.nii.gz
        if [ -e $inImg ]; then
            echo $sub >> $outCsv
            echo $sub,0,, >> $outQC
        fi
        i=$(( i + 1 ))
    done
else
    echo "Out list exists, skip: $outCsv"
fi
