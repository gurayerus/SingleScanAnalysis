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
list=${prjDir}/Lists/${prjName}_QCFlags.csv

inDir=${prjDir}/Data/RenamedNifti

imgMod='T1'
#imgMod='T2'
#imgMod='FL'

mkdir -pv ./Out
outCsv=./Out/List_ImgIntensity_${imgMod}.csv

######################### 
######################### 
###  Main

#########################
### Make list of missing cases
i=1
echo "Making list of max img intensities ..."
echo ID,MaxInt > $outCsv
for sub in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1
    echo "Sub $i : $sub"
    inImg=${inDir}/${sub}/${sub}_${imgMod}.nii.gz
    if [ -e $inImg ]; then
        m=`3dBrickStat -non-zero -max $inImg $inImg 2>/dev/null`
        echo $sub,$m >> $outCsv
    fi
    i=$(( i + 1 ))
done
