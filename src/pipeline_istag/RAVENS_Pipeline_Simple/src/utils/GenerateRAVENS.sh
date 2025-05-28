#!/bin/sh

# Get the utils directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## source bash functions
. ${SCRIPT_DIR}/BashUtilityFunctions.sh || { echo "Failed to source BashUtilityFunctions.sh!" 1>&2; exit 1; }

################################################ FUNCTIONS ################################################

# Usage info
help()
{
cat <<HELP

##############################################
    A wrapper to run DRAMMS on a given source and target image and generate the warped output
    image as well as generate RAVENS using the Jacobian DeterminDRAMMS

USAGE :	$0 [OPTIONS]
OPTIONS:

Required:
    [-s]  < file >	Source image file to be warped (absolute path)
    [-t]  < file >	Target image file to warp the source image to (absolute path)
    [-o]  < file >	Warped output image file (absolute path)
    [-l]  < file >	Label image file in the source image space (absolute path)
  
Optional:
    [-p]  < float > 	Regularization value (default: 0.1)
    [-i]  < str >    	Intensities in the label image for which the RAVENS are to be generated (default: 10,150,250)
    [-f]  < int >    	Scaling factor (default: 1000)
    [-m]  < str >	Registration methods to use (default: dramms)
    			Choose from { dramms,ants,demons }
    [-T]  < file >	Final template image defining the image space where the RAVENS are calculated (optional)
    			Image C (see below)
    [-d]  < file >	Prior deformation field to be composed to the newly caculated deformation (optional)
    			The deformation field should be in the same format as the method chosen in "-m"

			Composition of the deformation fields
    			T3(x) = (T2 o T1)(x) = T2[T1(x)]
    			T1(x) = A2B
    			T2(x) = B2C
    			T3(x) = A2C

	 
Examples:
		
ERROR: Not enough arguments!!
##############################################


HELP
exit 1
}

cleanUpandExit()
{
	echo -e ":o:o:o:o:o Aborting Operations .... \n\n"
	
	if [ -d "$TMP" ]
	then
		rm -rfv ${TMP}
	fi
	
	executionTime $startTimeStamp
	exit 1
}

parse()
{
	while [ -n "$1" ]; do
		case $1 in
			-h) 
				help;
				shift 1;;
   	  		-s) 
				input=$2;
				
				checkFile $input
				temp=`FileAtt $input`				
				InExt=`echo $temp | awk '{ print $1 }'`
				InbName=`echo $temp | awk '{ print $2 }'`
				InDir=`echo $temp | awk '{ print $3 }'`
				
				input=${InDir}/${InbName}.${InExt}
				
				shift 2;;
			-t) 
				ref=$2;
				
				checkFile $ref
				temp=`FileAtt $ref`				
				RefExt=`echo $temp | awk '{ print $1 }'`
				RefbName=`echo $temp | awk '{ print $2 }'`
				RefDir=`echo $temp | awk '{ print $3 }'`
				
				ref=${RefDir}/${RefbName}.${RefExt}

				shift 2;;
			-l) 
				lab=$2;
				
				checkFile $lab
				temp=`FileAtt $lab`				
				LabExt=`echo $temp | awk '{ print $1 }'`
				LabbName=`echo $temp | awk '{ print $2 }'`
				LabDir=`echo $temp | awk '{ print $3 }'`
				
				lab=${LabDir}/${LabbName}.${LabExt}

				shift 2;;
			-o) 
				output=$2;
				
				temp=`FileAtt ${output}.nii.gz`				
				OutExt=`echo $temp | awk '{ print $1 }'`
				OutbName=`echo $temp | awk '{ print $2 }'`
				OutDir=`echo $temp | awk '{ print $3 }'`
				
				output=${OutDir}/${OutbName}

				shift 2;;
			-d) 
				def=$2;
				
				checkFile $def
				shift 2;;
			-T) 
				template=$2;
				
				checkFile $template
				temp=`FileAtt $template`
				TempExt=`echo $temp | awk '{ print $1 }'`
				TempbName=`echo $temp | awk '{ print $2 }'`
				TempDir=`echo $temp | awk '{ print $3 }'`
				
				template=${TempDir}/${TempbName}.${TempExt}

				shift 2;;
			-i) 
				int=$2;
				shift 2;;
			-f) 
				scalefactor=$2;
				shift 2;;
			-p) 
				param=$2;
				shift 2;;
			-m) 
				method=$2;
				shift 2;;
			-*) 
				echo "ERROR: no such option $1";
				help;;
			 *) 
				break;;
		esac
	done
}

import()
{
	ext=$1
	inFile=$2
	outFile=$3
	
	if [ "${ext}" == "nii.gz" ]
	then
		set -x; nifti1_test -zn1 ${inFile} ${outFile}; set +x
	elif [ "${ext}" == "nii" ]
	then
		set -x; nifti1_test -zn1 ${inFile} ${outFile}; set +x
	elif [ "${ext}" == "hdr" ]
	then
		set -x; nifti1_test -zn1 ${inFile%.hdr}.img ${outFile}; set +x
	elif [ "${ext}" == "img" ]
	then
		set -x; nifti1_test -zn1 ${inFile} ${outFile}; set +x
	fi	
}

getDeformation()
{
	 method=$1
	 fixedImage=$2
	 movingImage=$3
	 outDef=$4
	 outWarp=$5
	 outJac=$6
	 param=$7
	 if [ -n "$8" ]
	 then
	 	priorDef=$8
	 else
	 	priorDef=""
	 fi
	 
	 if [ -n "$9" ]
	 then
	 	finalTemplate=$9
	 else
	 	finalTemplate=""
	 fi
	 
	 if [ $method == "dramms" ]
	 then
	 	echo -e "\n"
		set -x

		dramms \
		 -T ${fixedImage} \
		 -S ${movingImage} \
		 -D ${outDef%.nii.gz}_A2B.nii.gz \
		 -g ${param} \
		 -e 1 \
		 -m 2 \
		 -H 0.8 \
		 -c 1;

		set +x
		
		### If provided, compose the deformation with the newly calculated deformation field
		if [ -f "$priorDef" ]
		then
		 	echo -e "\n"
			set -x

			dramms-combine \
			 -c \
			 -v \
			 ${outDef%.nii.gz}_A2B.nii.gz \
			 $priorDef \
			 $outDef;

			set +x

		 	echo -e "\n"
			set -x

			dramms-jacobian \
			 ${outDef} \
			 ${outJac} \
			 -C;
#			 -f ${movingImage} \
#			 -t ${finalTemplate};

			set +x

		else
		 	echo -e "\n"
			set -x

			mv -v \
			 ${outDef%.nii.gz}_A2B.nii.gz \
			 $outDef;
			
			set +x

		 	echo -e "\n"
			set -x

			dramms-jacobian \
			 ${outDef} \
			 ${outJac} \
			 -C;
#			 -f ${movingImage} \
#			 -t ${fixedImage};

			set +x
		fi
		
				 
		rm -fv \
		 ${outDef%.nii.gz}_A2B.nii.gz;
		 
		set +x
		
	elif [ $method == "ants" ]
	then
	 	echo -e "\n"
		set -x

		ANTS \
		 3 \
		 -m PR[${fixedImage},${movingImage},1,2] \
		 -i 10x50x50x10 \
		 -o ${outWarp} \
		 -t SyN[${param}] \
		 -r Gauss[2,0];

		set +x

	 	echo -e "\n"
		set -x

		ComposeMultiTransform \
		 3 \
		 ${outDef%.nii.gz}_A2B.nii.gz \
		 -R ${fixedImage} \
		 ${outWarp%.nii.gz}Warp.nii.gz \
		 ${outWarp%.nii.gz}Affine.txt;

		set +x
		
		### If provided, compose the deformation with the newly calculated deformation field
		if [ -f "$priorDef" ]
		then
		 	echo -e "\n"
			set -x

			ComposeMultiTransform \
			 3 \
			 ${outDef} \
			 -R ${finalTemplate} \
			 $priorDef \
			 ${outDef%.nii.gz}_A2B.nii.gz;

			set +x
		else
		 	echo -e "\n"
			set -x

			mv -v \
			 ${outDef%.nii.gz}_A2B.nii.gz \
			 $outDef;

			set +x			 
		fi

	 	echo -e "\n"
		set -x

#		ANTSJacobian \
#		 3 \
#		 ${outDef} \
#		 ${outDef%.nii.gz}_;

		CreateJacobianDeterminantImage \
		 3 \
		 ${outDef} \
		 ${outDef%.nii.gz}_jacobian.nii.gz;

		set +x


		mv -v ${outDef%.nii.gz}_jacobian.nii.gz ${outJac}
		
		rm -fv \
		 ${outWarp%.nii.gz}Warp.nii.gz \
		 ${outWarp%.nii.gz}Affine.txt \
		 ${outWarp%.nii.gz}InverseWarp.nii.gz \
		 ${outDef%.nii.gz}_grid.nii.gz \
		 ${outDef%.nii.gz}_A2B.nii.gz;
		
	elif [ $method == "demons" ]
	then
	 	echo -e "\n"
		set -x

		ANTS \
		 3 \
		 -m MI[${fixedImage},${movingImage},1,32] \
		 -o ${outWarp%.nii.gz}_ANTSAFFINE.nii.gz \
		 -i 0 \
		 --use-Histogram-Matching \
		 --number-of-affine-iterations 1000x1000x1000x1000x1000 \
		 --rigid-affine true \
		 --affine-gradient-descent-option 0.5x0.95x1.e-4x1.e-4;
		
		set +x

	 	echo -e "\n"
		set -x

		WarpImageMultiTransform \
		 3 \
		 ${movingImage} \
		 ${outWarp%.nii.gz}_ANTSAFFINE.nii.gz \
		 -R ${fixedImage} \
		 ${outWarp%.nii.gz}_ANTSAFFINEAffine.txt;

		set +x
				
	 	echo -e "\n"
		set -x

		/cbica/software/external/ITK/centos6/4.11.0/AMD-Opteron/bin/VariationalRegistration \
		 -F ${fixedImage} \
		 -M ${outWarp%.nii.gz}_ANTSAFFINE.nii.gz \
		 -O ${outWarp%.nii.gz}_ANTSAFFINE_DEMONS_def.nii.gz \
		 -i 100 \
		 -l 3 \
		 -t 1 \
		 -s 2 \
		 -r 0 \
		 -v $param \
		 -d 2 \
		 -h 1;

		set +x
		
	 	echo -e "\n"
		set -x

		ComposeMultiTransform \
		 3 \
		 ${outDef%.nii.gz}_A2B.nii.gz \
		 -R ${fixedImage} \
		 ${outWarp%.nii.gz}_ANTSAFFINE_DEMONS_def.nii.gz \
		 ${outWarp%.nii.gz}_ANTSAFFINEAffine.txt;

		set +x
		
		### If provided, compose the deformation with the newly calculated deformation field
		if [ -f "$priorDef" ]
		then
		 	echo -e "\n"
			set -x

			ComposeMultiTransform \
			 3 \
			 ${outDef} \
			 -R ${finalTemplate} \
			 $priorDef \
			 ${outDef%.nii.gz}_A2B.nii.gz;

			set +x
		else
		 	echo -e "\n"
			set -x

			mv -v \
			 ${outDef%.nii.gz}_A2B.nii.gz \
			 $outDef;

			set +x			 
		fi

	 	echo -e "\n"
		set -x

#		ANTSJacobian \
#		 3 \
#		 ${outDef} \
#		 ${outDef%.nii.gz}_;

		CreateJacobianDeterminantImage \
		 3 \
		 ${outDef} \
		 ${outDef%.nii.gz}_jacobian.nii.gz;

		set +x


		mv -v ${outDef%.nii.gz}_jacobian.nii.gz ${outJac}
		
		rm -fv \
		 ${outWarp%.nii.gz}_ANTSAFFINE.nii.gz \
		 ${outWarp%.nii.gz}_ANTSAFFINEAffine.txt \
		 ${outWarp%.nii.gz}_ANTSAFFINE_DEMONS_def.nii.gz \
		 ${outDef%.nii.gz}_A2B.nii.gz;

	fi

	 
}

warpImages()
{
	method=$1
	movingImage=$2
	outDef=$3
	outWarp=$4
	fixedImage=$5
	
	if [ $method == "dramms" ]
	then
	 	echo -e "\n"
		set -x

		dramms-warp \
		 $movingImage \
		 $outDef \
		 $outWarp \
		 -t $fixedImage \
		 -v;

		set +x
		 
	elif [ $method == "ants" ] || [ $method == "demons" ]
	then
	 	echo -e "\n"
		set -x

		WarpImageMultiTransform \
		 3 \
		 $movingImage \
		 $outWarp \
		 -R $fixedImage \
		 $outDef;

		set +x
	fi
}


calculateRAVENS()
{
	method=$1
	outRavens=$2
	outJac=$3
	warpedLabel=$4
	movingImage=$5
	
	if [ $method == "dramms" ]
	then
		# Calculate voxel volume
		voxvol=1
		for i in `fslinfo ${movingImage} | grep ^pixdim | awk '{ print $2 }' | head -3`
		do 
			voxvol=`echo "scale=9; $voxvol * $i" | bc`
		done

		# get RAVENS in float format
	 	echo -e "\n"
		set -x

		3dcalc \
		 -prefix ${outRavens%.nii.gz}_float.nii.gz \
		 -a ${outJac} \
		 -b ${warpedLabel} \
		 -expr "a*b*$scalefactor*$voxvol" \
		 -verbose \
		 -nscale \
		 -float;

		set +x
	
	elif [ $method == "ants" ] || [ $method == "demons" ]
	then
		# get RAVENS in float format
	 	echo -e "\n"
		set -x

		3dcalc \
		 -prefix ${outRavens%.nii.gz}_float.nii.gz \
		 -a ${outJac} \
		 -b ${warpedLabel} \
		 -expr "a*b*$scalefactor" \
		 -verbose \
		 -nscale \
		 -float;

		set +x

	fi
		
	# get RAVENS in short format
 	echo -e "\n"
	set -x

	3dcalc \
	 -prefix ${outRavens} \
	 -a ${outRavens%.nii.gz}_float.nii.gz \
	 -expr "a*step(32767-a) + 32767*step(a-32767)" \
	 -nscale \
	 -verbose \
	 -short;
	set +x

}

################################################ END OF FUNCTIONS ################################################

################################################ MAIN BODY ################################################

### Making sure the POSIXLY_CORRECT variable is unset as it causes bash to misbehave
if [ ${POSIXLY_CORRECT} ]
then
	unset  POSIXLY_CORRECT
fi

### Checking for the number of arguments
if [ $# -lt 8 ]
then
	help
fi

### Timestamps
startTime=`date +%F-%H:%M:%S`
startTimeStamp=`date +%s`

echo -e "\nRunning commands on		: `hostname`"
echo -e "Start time			: ${startTime}\n"

### Default parameters
param=0.1
int=10,150,250
scalefactor=1000
verbose=1
method=1
def=""
template=""

FSLOUTPUTTYPE=NIFTI_GZ; export $FSLOUTPUTTYPE

### Specifying the trap signal
trap "checkExitCode 1 '\nProgram Interrupted. Received SIGHUP signal'" SIGHUP 
trap "checkExitCode 1 '\nProgram Interrupted. Received SIGINT signal'" SIGINT 
trap "checkExitCode 1 '\nProgram Interrupted. Received SIGTERM signal'" SIGTERM 
trap "checkExitCode 1 '\nProgram Interrupted. Received SIGKILL signal'" SIGKILL

### Reading the arguments
echo -e "\nParsing arguments		: $*"
parse $*

### Sanity checks on the parameters
# Checking if required options are provided
if [ -z "$input" ]
then
	echo -e "\nERROR: Input/Source file not provided!!!"
	exit 1
fi

if [ -z "$ref" ]
then
	echo -e "\nERROR: Reference/Target file not provided!!!"
	exit 1
fi

if [ -z "$lab" ]
then
	echo -e "\nERROR: Input label/segmented file not provided!!!"
	exit 1
fi

if [ -z "$output" ]
then
	echo -e "\nERROR: Output warped file not provided!!!"
	exit 1
fi

# if running demons, load the new itk module so the exec VariationalRegistration is available in the path
if [ $method == "demons" ]
then
	echo -e "\nLoading module itk/4.13.0\n"
	module load itk/4.13.0
fi

### Forming FileNames
methodSuffix=${method}-${param}

PID=$$
createTempDir GenerateRAVENS $PID
echo -e "\n----->	Temporary local directory created at $TMP ..."

### Importing data to the temporary directory
echoV "----->	Importing required files to the temporary local directory ..." 1

import ${InExt} ${input} ${TMP}${InbName}
import ${RefExt} ${ref} ${TMP}${RefbName}
import ${LabExt} ${lab} ${TMP}${LabbName}

### Run warping
echo -e "\n----->	Performing Deformable Registration between Input and Reference Images ...\n"

if [ -f $def ] && [ -f $template ]
then
	additionalOpts="$def $template"
else
	additionalOpts=""
fi

getDeformation \
 $method \
 ${TMP}${RefbName}.nii.gz \
 ${TMP}${InbName}.nii.gz \
 ${TMP}${OutbName}_${methodSuffix}_def.nii.gz \
 ${TMP}${OutbName}_${methodSuffix}.nii.gz \
 ${TMP}${OutbName}_${methodSuffix}_jacobian.nii.gz \
 $param \
 $additionalOpts;




### Warp the original and label/segmented image to the reference space
if [ -f ${TMP}${OutbName}_${methodSuffix}_def.nii.gz ]
then
	echo -e "\n----->	Warp the original and label/segmented image to the reference space ...\n"
	
	# Determine which template to use as reference
	if [ -f "$template" ]
	then
		finalTemplate=$template
	else
		finalTemplate=${TMP}${RefbName}.nii.gz
	fi
	
	warpImages \
	 $method \
	 ${TMP}${InbName}.nii.gz \
	 ${TMP}${OutbName}_${methodSuffix}_def.nii.gz \
	 ${TMP}${OutbName}_${methodSuffix}.nii.gz \
	 $finalTemplate;
	 
	for i in `echo $int | sed 's/,/ /g'`
	do
		set -x
		
		# separate each label to warp them
		3dcalc \
		 -prefix ${TMP}${LabbName}_${i}.nii.gz \
		 -a ${TMP}${LabbName}.nii.gz"<${i}>" \
		 -expr "step(a)" \
		 -verbose \
		 -nscale \
		 -float;
		
		# warp each label
		warpImages \
		 $method \
		 ${TMP}${LabbName}_${i}.nii.gz \
		 ${TMP}${OutbName}_${methodSuffix}_def.nii.gz \
		 ${TMP}${LabbName}_${i}_warped.nii.gz \
		 $finalTemplate;
		
		set +x
	done
else
	cleanUpandExit
fi


### Calculate RAVENS for each of the label intensities
if [ -f ${TMP}${OutbName}_${methodSuffix}_def.nii.gz ]
then
	echo -e "\n----->	Calculate RAVENS maps for each of the label intensities ...\n"
	for i in `echo $int | sed 's/,/ /g'`
	do
#		calculateRAVENS \
#		 $method \
#		 ${TMP}${OutbName}_${methodSuffix}_RAVENS_${i}.nii.gz \
#		 ${TMP}${OutbName}_${methodSuffix}_jacobian.nii.gz \
#		 ${TMP}${LabbName}_${i}_warped.nii.gz \
#		 ${TMP}${InbName}.nii.gz;

		calculateRAVENS \
		 $method \
		 ${TMP}${LabbName}_${methodSuffix}_RAVENS_${i}.nii.gz \
		 ${TMP}${OutbName}_${methodSuffix}_jacobian.nii.gz \
		 ${TMP}${LabbName}_${i}_warped.nii.gz \
		 ${TMP}${InbName}.nii.gz;
	done
else
	cleanUpandExit
fi

### Move results to destination
echo -e "\n----->	Move results to destination ...\n"
mkdir -pv ${OutDir}/

mv -v ${TMP}${OutbName}_${methodSuffix}.nii.gz ${OutDir}/${OutbName}_${methodSuffix}.nii.gz
mv -v ${TMP}${OutbName}_${methodSuffix}_jacobian.nii.gz ${OutDir}/${OutbName}_${methodSuffix}_JacDet.nii.gz

for i in `echo $int | sed 's/,/ /g'`
do
	mv -v ${TMP}${LabbName}_${methodSuffix}_RAVENS_${i}.nii.gz ${OutDir}/${LabbName}_${methodSuffix}_RAVENS_${i}.nii.gz
done
#mv -v ${TMP}/* ${OutDir}/

### Remove unnecessary files
echo -e "\n----->	Removing unnecessary files ...\n"
rm -rfv ${TMP}  

### Execution Time 
executionTime $startTimeStamp

################################################ END ################################################
