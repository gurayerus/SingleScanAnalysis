#! /bin/bash +x

########################################
### Input args
prjName='ADNI'
prjDir='/cbica/projects/ADNI/Pipelines/ADNI_DLICV_2022'
############################################################

list=${prjDir}/Lists/${prjName}_QCFlags.csv

inDir=${prjDir}/Protocols/FSeTIV
outDir=${prjDir}/Results/TIV

mkdir -pv $outDir

outCsv=${outDir}/${prjName}_ETIV.csv

i=1
if [ -e $outCsv ]; then
    echo "Out csv exists, skip: $outCsv"
    
else
    for ll in `sed 1d $list | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1`; do        ## Remove scans with QCFail flag set to 1
        echo "Append file no: $i $ll"
        inTmp=${inDir}/CSFROI_${ll}.csv
        if [ -e $inTmp ]; then
            if [ ! -e $outCsv ]; then
                echo SCID,ETIV > $outCsv
            fi
            cat $inTmp >> $outCsv
        fi
        
        i=$(( i + 1 ))
    done
fi
            



