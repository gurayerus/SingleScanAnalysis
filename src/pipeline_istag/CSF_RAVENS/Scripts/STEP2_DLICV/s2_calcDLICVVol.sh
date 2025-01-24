#! /bin/bash +x

export FSLOUTPUTTYPE=NIFTI_GZ

########################################
### Project specific vars
### Edit for each project
prjName='OASIS3'
prjDir='/cbica/projects/OASIS/OASIS3/Pipelines/OASIS3_DLICV_2022'
########################################

list=${prjDir}/Lists/${prjName}_QCFlags.csv

outDir=${prjDir}/Results/DLICV
outCsv=${outDir}/${prjName}_DLICVVol.csv

mkdir -pv ${outDir}

if [ ! -e $outCsv ]; then
    echo MRID,DLICVVol > $outCsv

    for sub in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1

        DLICV=${prjDir}/Protocols/DLICV/${sub}/${sub}_T1_LPS_dlicvmask.nii.gz

        if [ -e $DLICV ]; then
            vol=`3dBrickStat -non-zero -volume ${DLICV} 2>/dev/null`
            echo $sub,$vol >> $outCsv
        fi
    done
    
fi
