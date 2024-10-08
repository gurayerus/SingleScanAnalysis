#! /bin/bash +x

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

l1="${prjDir}/Lists/${prjName}_QCFlags.csv"
l2="${prjDir}/Results/DLICV/${prjName}_DLICVVol.csv"
l3="${prjDir}/Results/CSF-ROIs-Dil/${prjName}_CSF-ROIs-Dil3.csv"
l4="${prjDir}/Results/CSF-DerivedROIs-Dil/${prjName}_CSF-DerivedROIs-Dil3.csv"
l5="${prjDir}/Results/FAST_Seg/${prjName}_FAST_Vol.csv"

mkdir -pv ./Out

sed 1d $l1 | cut -d, -f1 | sort -u > ./Out/tmp1.csv
sed 1d $l1 | cut -d, -f1,2 | grep -v ,1 | cut -d, -f1 | sort -u > ./Out/tmp2.csv
sed 1d $l2 | cut -d, -f1 | sort -u > ./Out/tmp3.csv
sed 1d $l3 | cut -d, -f1 | sort -u > ./Out/tmp4.csv
sed 1d $l4 | cut -d, -f1 | sort -u > ./Out/tmp5.csv
sed 1d $l5 | cut -d, -f1 | sort -u > ./Out/tmp6.csv

n1=`cat ./Out/tmp1.csv | wc -l`
n2=`cat ./Out/tmp2.csv | wc -l`
n3=`cat ./Out/tmp3.csv | wc -l`
n4=`cat ./Out/tmp4.csv | wc -l`
n5=`cat ./Out/tmp5.csv | wc -l`
n6=`cat ./Out/tmp6.csv | wc -l`

echo "Num Init : ${n1}"
echo "Num QCOK : ${n2}"
echo "Num DLIC : ${n3}"
echo "Num CSFR : ${n4}"
echo "Num CSFD : ${n5}"
echo "Num FAST : ${n6}"

if [ "${n2}" != "${n3}" ]; then
    echo "Missing DLICV : "
    diff ./Out/tmp2.csv ./Out/tmp3.csv | grep '<' | cut -d' ' -f2 | sort -u
fi

if [ "${n2}" != "${n4}" ]; then
    echo "Missing CSFROI : "
    diff ./Out/tmp2.csv ./Out/tmp4.csv | grep '<' | cut -d' ' -f2 | sort -u
fi

if [ "${n2}" != "${n5}" ]; then
    echo "Missing Derived CSFROI : "
    diff ./Out/tmp2.csv ./Out/tmp5.csv | grep '<' | cut -d' ' -f2 | sort -u
fi

if [ "${n2}" != "${n6}" ]; then
    echo "Missing Derived CSFROI : "
    diff ./Out/tmp2.csv ./Out/tmp6.csv | grep '<' | cut -d' ' -f2 | sort -u
fi

# echo SCID,T1,DL,CSF > ./Out/tmp4.csv
# for ll in `cat ./Out/tmp3.csv`; do
#     t1=`ls -1 ../../Protocols/ReOrientedLPS/${ll}/${ll}_T1_LPS.nii.gz 2>/dev/null | wc -l`
#     dl=`ls -1 ../../Protocols/DLICV/${ll}/${ll}_T1_LPS_dlicv.nii.gz 2>/dev/null | wc -l`
#     csf=`ls -1 ../../Protocols/CSF-RAVENS/${ll}/${ll}_T1_LPS_dlicv_seg_ants-0.3_RAVENS_1.nii.gz 2>/dev/null | wc -l`
#     
#     echo $ll,$t1,$dl,$csf >> ./Out/tmp4.csv
# done
    
    

