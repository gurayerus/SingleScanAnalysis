#! /bin/bash +x

export FSLOUTPUTTYPE=NIFTI_GZ

sub=$1
seg=$2
out=$3

echo 'Running:'
echo $0 $1 $2 $3

if [ -e $seg ] && [ ! -e $out ]; then
    v1=`3dBrickStat -non-zero -volume ${seg}'<1>' 2>/dev/null`
    v2=`3dBrickStat -non-zero -volume ${seg}'<2>' 2>/dev/null`
    v3=`3dBrickStat -non-zero -volume ${seg}'<3>' 2>/dev/null`
#    echo $sub,$v1,$v2,$v3
    echo $sub,$v1,$v2,$v3 > $out
fi
    
