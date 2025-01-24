#! /bin/bash +x

########################################
### Input args
prjName='OASIS3'
prjDir='/cbica/projects/OASIS/OASIS3/Pipelines/OASIS3_DLICV_2022'

list=${prjDir}/Lists/${prjName}_QCFlags.csv

inDir=${prjDir}/Protocols/FAST
outDir=${prjDir}/Results/FAST_Seg

mkdir -pv $outDir

outCsv=${outDir}/${prjName}_FAST_Vol.csv

i=1
if [ -e $outCsv ]; then
    echo "Out csv exists, skip: $outCsv"
    
else
    for ll in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1
        echo "Append file no: $i $ll"
        inTmp=${inDir}/${ll}/${ll}_T1_LPS_dlicv_seg_Vol.csv
        if [ -e $inTmp ]; then
            if [ ! -e $outCsv ]; then
                echo "SCID,Vol1,Vol2,Vol3" > $outCsv
            fi
            cat $inTmp >> $outCsv
        fi
        
        i=$(( i + 1 ))
    done
fi
            



