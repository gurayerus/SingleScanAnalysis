#! /bin/bash +x

export FSLOUTPUTTYPE=NIFTI_GZ

########################################
### Project specific vars
### Edit for each project
prjName='ADNI'
prjDir='/cbica/projects/ADNI/Pipelines/ADNI_DLICV_2022'
########################################

list=${prjDir}/Lists/${prjName}_QCFlags.csv

i=1
for sub in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1

    echo "Subj $i"

    subCsv=${prjDir}/Protocols/DLICV/${sub}/${sub}_T1_LPS_dlicvVol.csv
    DLICV=${prjDir}/Protocols/DLICV/${sub}/${sub}_T1_LPS_dlicvmask.nii.gz
    if [ ! -e $subCsv ]; then
        if [ -e $DLICV ]; then
            vol=`3dBrickStat -non-zero -volume ${DLICV} 2>/dev/null`
            echo $sub,$vol > $subCsv
        fi
    fi
    i=$(( i + 1 ))
    
done

outDir=${prjDir}/Results/DLICV
outCsv=${outDir}/${prjName}_DLICVVol.csv
mkdir -pv ${outDir}

if [ ! -e $outCsv ]; then
    echo MRID,DLICVVol > $outCsv

    for sub in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1

        subCsv=${prjDir}/Protocols/DLICV/${sub}/${sub}_T1_LPS_dlicvVol.csv

        if [ -e $subCsv ]; then
            cat $subCsv >> $outCsv
        fi
    done
    
fi
