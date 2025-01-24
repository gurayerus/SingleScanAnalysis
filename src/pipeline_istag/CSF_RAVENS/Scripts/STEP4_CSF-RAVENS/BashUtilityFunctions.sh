#!/bin/sh

### echo the statement if the verbose option is on
echoV()
{
	if [ "$verbose" == "1" ] && [ -z $2 ]
	then
		echo -e $1
	elif [ "$verbose" == "1" ] && [ "$2" == "1" ]
	then
		echo -e "\n$1\n"
	elif [ "$verbose" == "0" ] && [ "$2" == "1" ]
	then
		echo -e $1
	fi
}

### Calculate the execution time for the script to finish
executionTime()
{
	executionTimestartTimeStamp=$1

	executionTimeendTimeStamp=`date +%s`
	executionTimetotal=$[ (${executionTimeendTimeStamp} - ${executionTimestartTimeStamp}) ]
	executionTimetotalMins=`echo "scale=4; $executionTimetotal / 60" | bc`
	
	if [ ${executionTimetotal} -gt 60 ]
	then
		if [ ${executionTimetotal} -gt 3600 ]
		then
			if [ ${executionTimetotal} -gt 86400 ]
			then
				echoV "\nExecution time:  $executionTimetotalMins mins ( $[ ${executionTimetotal} / 86400]d $[ ${executionTimetotal} % 86400 / 3600]h $[ ${executionTimetotal} % 86400 % 3600 / 60]m $[ ${executionTimetotal} % 86400 % 3600 % 60]s )" 1
			else
				echoV "\nExecution time:  $executionTimetotalMins mins ( $[ ${executionTimetotal} / 3600]h $[ ${executionTimetotal} % 3600 / 60]m $[ ${executionTimetotal} % 3600 % 60]s )" 1
			fi
		else
			echoV "\nExecution time:  $executionTimetotalMins mins ( $[ ${executionTimetotal} / 60]m $[ ${executionTimetotal} % 60]s )" 1
		fi
	else
		echoV "\nExecution time:  $executionTimetotalMins mins ( $[ ${executionTimetotal} % 60]s )" 1
	fi
}

### Add a / at the end of the path if required
checkPath()
{
	Inpath=${1##*/}
	
	if [ -n "$Inpath" ]
	then
		echo ${1}/
	else
		echo $1
	fi
}

### Get File Attributes
FileAtt()
{
	FileAttIP=$1;
	
	FileAttdir="$(cd "$(dirname "$FileAttIP")" && pwd -P)"
	FileAttext=${FileAttIP##*.}
	FileAttbName=`basename ${FileAttIP%.${FileAttext}}`
	
	if [ "$FileAttext" == "gz" ]
	then
		FileAttext=${FileAttbName##*.}.${FileAttext}
		FileAttbName=`basename ${FileAttIP%.${FileAttext}}`
	fi
	
	if [ "$FileAttext" != "nii.gz" ] && [ "$FileAttext" != "hdr" ] && [ "$FileAttext" != "img" ] && [ "$FileAttext" != "nii" ]
	then
		echo -e "\nERROR: Input file extension $FileAttext not recognized! Please check ..."
		cleanUpandExit
	fi
	
	echo $FileAttext $FileAttbName $FileAttdir
}

### Check if the input file exists
checkFile()
{
	if [ ! -f "$1" ] && [ ! -L "$1" ]
	then
		echo -e "\nERROR: Input file $1 does not exist! Aborting operations ..."
		cleanUpandExit
	fi
}

### Check if the dependency is installed and is in the default path or not
checkDependency()
{
	checkDependencypth=`which $1 2>&1`
	if [ $? != 0 ]
	then
		echo -e "${1} not installed OR not found. Aborting operations ..."
		cleanUpandExit
	fi
}

### Check the exit code of the program and call the appropriate exit function
checkExitCode()
{
	if [ $1 != 0 ]
	then
		echo -e $2
		if [ -f ${TMP}Debug.log ]
		then
			echo -e "\n Traceback of the last command ..."
			cat ${TMP}Debug.log
		fi
		cleanUpandExit
	fi
}

### Remove files
rmV()
{
	for FileToBeDeleted in $*
	do
		if [ -f $FileToBeDeleted ]
		then
			if [ "$verbose" == "1" ]
			then
				rm -fv $FileToBeDeleted
			else
				rm -f $FileToBeDeleted
			fi
		fi
	done
}
	
### Move or rename files
mvV()
{
	if [ -f $1 ]
	then
		if [ "$verbose" == "1" ]
		then
			mv -v $1 $2
		else
			mv $1 $2
		fi
	fi
}

### Create directories
mkdirV()
{
	if [ ! -d $1 ]
	then
		if [ "$verbose" == "1" ]
		then
			mkdir -pv $1
		else
			mkdir -p $1
		fi
	fi
}

### Remove directories
rmdirV()
{
	if [ -d $1 ]
	then
		if [ "$verbose" == "1" ]
		then
			rmdir -v $1
		else
			rmdir $1
		fi
	fi
}

### Convert the file to NIFTI_GZ
convertToNifti()
{
	convertToNiftiInput=$1
	
	convertToNiftitemp=`FileAtt $convertToNiftiInput`				
	convertToNiftiInExt=`echo $convertToNiftitemp | awk '{ print $1 }'`
	convertToNiftiInbName=`echo $convertToNiftitemp | awk '{ print $2 }'`
	convertToNiftiInDir=`dirname $convertToNiftiInput`

	if [ ! -f ${convertToNiftiInDir}/${convertToNiftiInbName}.nii.gz ]
	then
		if [ "${convertToNiftiInExt}" == "nii.gz" ] || [ "${convertToNiftiInExt}" == "nii" ] || [ "${convertToNiftiInExt}" == "img" ]
		then
			nifti1_test -zn1 ${convertToNiftiInput} ${convertToNiftiInDir}/${convertToNiftiInbName}
		elif [ "${convertToNiftiInExt}" == "hdr" ]
		then
			nifti1_test -zn1 ${convertToNiftiInput%.hdr}.img ${convertToNiftiInDir}/${convertToNiftiInbName}
		fi	
	fi

	if [ -f ${convertToNiftiInDir}/${convertToNiftiInbName}.nii.gz ]
	then
		echoV "\nConverted to NIFTIGZ: $convertToNiftiInput"
		if [ "${convertToNiftiInExt}" == "nii" ]
		then
			rmV ${convertToNiftiInput}
		elif [ "${convertToNiftiInExt}" == "hdr" ]
		then
			rmV ${convertToNiftiInput%.hdr}.img
			rmV ${convertToNiftiInput}
		elif [ "${convertToNiftiInExt}" == "img" ]
		then
			rmV ${convertToNiftiInput%.img}.hdr
			rmV ${convertToNiftiInput}		
		fi	
	else
		echoV "\nConversion to NIFTIGZ failed: $1"
	fi


#	nifti1_test -zn1 $1 $1

#	if [ -f ${1%.img}.nii.gz ]
#	then
#		echoV "\nConverted to NIFTIGZ: $1"
#		rmV ${1} 
#		rmV ${1%.img}.hdr
#	else
#		echoV "\nConversion to NIFTIGZ failed: $1"
#	fi
}

### Creating temporary directory
createTempDir()
{
	tmpDirPref=$1
	tmpDirPID=$2
	
	# Decide the directory prefix
	if [ -n "$tmp" ]
	then
		LocalTempDir=$tmp

	elif [ -n "$SBIA_TMPDIR" ]
	then
		LocalTempDir=$SBIA_TMPDIR
	elif [ -n "$TMPDIR" ]
	then
		LocalTempDir=$TMPDIR
	else
		LocalTempDir=/tmp	
	fi

	# Create the LocalTempDir directory if it doesn't exist
	if [ ! -d "$LocalTempDir" ]
	then
		mkdirV $LocalTempDir
	fi

	# Create the temp dir
	TMP=`mktemp -d -p ${LocalTempDir} ${tmpDirPref}_${tmpDirPID}.XXXXXXXXXX`/ || { echo -e "\nCreation of Temporary Directory failed."; exit 1; }
}
