#! /bin/bash

##############################################
## Hard coded args
pdir='/cbica/projects/ADNI/Pipelines/ADNI_DLICV_2022'

exedir="${pdir}/Scripts/STEP4_CSF-RAVENS"

tImg=${pdir}/Templates/colin27_t1_tal_lin/Images/colin27_t1_tal_lin_INV.nii.gz
tSeg=${pdir}/Templates/colin27_t1_tal_lin/Images/colin27_t1_LPS_dlicv_seg.nii.gz

tName='COLIN27'

RavensReg=0.3
RavensScaleFactor=1000
method=ants
##############################################

export FSLOUTPUTTYPE='NIFTI_GZ'

sub=$1
t1=$2
t1seg=$3
odir=$4

mkdir -pv ${odir}

##############################################
## create inverted image
echo; echo "Creating inverted img ..."
oimg=${odir}/${sub}_T1_LPS_dlicv_inv.nii.gz
if [ ! -e $oimg ]; then

    ## Scale img
    min=$(3dBrickStat -slow -min $t1)
    max=$(3dBrickStat -slow -max $t1)
    3dcalc -a $t1 -expr "((a-${min})/(${max}-${min}))*2048" -short -nscale -prefix ${odir}/tmp_csfravens_1.nii.gz

    ## Invert img intensities
    max=$(3dBrickStat -slow -max ${odir}/tmp_csfravens_1.nii.gz)
    3dcalc -a ${odir}/tmp_csfravens_1.nii.gz -expr "$max - a" -prefix ${odir}/tmp_csfravens_2.nii.gz

    ## Mask to ICV region
    3dcalc -a ${odir}/tmp_csfravens_2.nii.gz -b $t1 -expr "a*step(b)" -prefix ${oimg}                           

    rm -rf ${odir}/tmp_csfravens_*
else
    echo "Skip, out img exists ..."
fi

##############################################
## Make CSF RAVENS Img
echo; echo "Register to atlas ..."
oimg=${odir}/${sub}_T1_LPS_dlicv_seg_${method}-${RavensReg}_RAVENS_1.nii.gz
if [ ! -e $oimg ]; then
    sImg=${odir}/${sub}_T1_LPS_dlicv_inv.nii.gz
    sSeg=${t1seg}
    oWarp=${odir}/${sub}_T1_LPS_dlicv_inv_warpedTo-${tName}
    
    mem=''
    if [ "${method}" == 'dramms' ]; then
        mem='-l h_vmem=12G'
    fi
    
    ${exedir}/GenerateRAVENS.sh -s $sImg -t ${tImg} -o $oWarp -l ${sSeg} -p ${RavensReg} -i 1 -f ${RavensScaleFactor} -m $method
    
    ## Remove Jacobian determinant
    rm -rf ${oWarp}_${method}-${RavensReg}_JacDet.nii.gz

    ######################################
    ## Optional to reduce disk space
    ######################################
    ## Remove warped t1
    rm -rf ${oWarp}_${method}-${RavensReg}.nii.gz
    
    
else
    echo "Skip, out img exists ..."
fi
