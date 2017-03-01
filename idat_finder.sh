#!/bin/bash

function usage() { 
	cat <<EOF
Help: 		This script locates the .idat files as supplied by the 
		phenodata file containing the Sentrix ID and positions. 
		The general filename of an .idat file is:

		[Sentrix_ID]_[Sentrix_Position]_[Grn/Red].idat 

		Additionally, the .idat files are then copied into the 
		working directory whereby each Sentrix ID gets a 
		separate subdirectory.

Usage: 		$0 [-s] phenodata [-f] path/to/idats_folder/ [-o] path/to/output_folder [-v] [-d] [-h]
	-s 	Phenodata containing the Sentrix ID and positions of 
		the arrays.
		
		phenodata.txt
		Sentrix_ID	Sentrix_Pos	Sample_ID
		29247582	R01C02		Sample_1
		29247582	R02C05		Sample_2
		...
		29249528	R02C06		Sample_9

	-f 	Source folder that contains the subfolders 
		containing the .idat files.
	-o 	Output folder that will contain the subdirectories, 
		which in turn contain the .idat files.
	-v	Executes and prints verbose messages.
	-h	Basic help function (the current screen).

EOF
}

verbose=0

while getopts "s:f:o:vh" opt; do
	case "$opt" in
		s) 
			phenodata=${OPTARG}
			if [ ! -e $phenodata ]; then
				echo "Phenodata was not found"
				exit 1
			fi
			;;
		f) 
			source_dir=${OPTARG}
			if [ ! -d $source_dir ]; then
				echo "Source folder was not found"
				exit 1
			fi
			;;
		o) 
			output_dir=${OPTARG}
			;;
		v) 	verbose=$((verbose+1))
			;;
		h)	
			usage
			exit 1
			;;
		*)
			echo "Invalid option: -$OPTARG" >&2			
			usage
			exit 1
			;;
	esac
done

# Check if phenodata and source folder are provided and check the entire filepath is provided, else prepend that to them

if [ -z $phenodata ]; then
	echo "Phenodata was not provided"
	usage
	exit 1
else
	if [[ "$phenodata" != /* ]]; then
		phenodata=`pwd`/$phenodata
	fi
fi
if [ -z $source_dir ]; then
	echo "Source folder was not provided"
	usage
	exit 1
else
	if [[ "$source_dir" != /* ]]; then
		source_dir=`pwd`/$source_dir/
	fi
fi

# Make a directory for the files to be copied to
if [ ! -z $output_dir ]; then
	if [ -d $output_dir ]; then
		cd $output_dir
	elif [ ! -d "$output_dir" ]; then
		if [ $verbose -eq 1 ]; then
			echo "Could not find specified output directory, making one now"
		fi
		mkdir $output_dir 
		cd $output_dir
	fi
else 
	if [ $verbose -eq 1 ]; then
		echo "No output directory specified, making one now"
	fi
	mkdir output
	cd output
fi

sentrix_id=($(awk 'BEGIN{FS=","}{for(i=1;i<=NF;++i)if($i~/^[0-9]{12}$/)print $i}' $phenodata))
sentrix_pos=($(awk 'BEGIN{FS=","}{for(i=1;i<=NF;++i)if($i~/^R[0-9]{2}C[0-9]{2}$/)print $i}' $phenodata))

#If verbose, print out the Sentrix IDs and the Sentrix positions
if [ $verbose -eq 1 ]; then
	echo 'Found the following entries in the phenodata:'
	echo -e 'Sentrix_ID \t Sentrix_pos' 

	for ((i=0;i<${#sentrix_id[@]};++i)); do
		echo -e ${sentrix_id[i]} '\t' ${sentrix_pos[i]}
	done
fi

##In case the number of Sentrix IDs do not correspond to the number of Sentrix positions throw an error and exit
if [ "${#sentrix_id[@]}" -ne "${#sentrix_pos[@]}" ]; then
	echo "Number of Sentrix IDs ("${#sentrix_id[@]}") do not correspond with the number of Sentrix positions ("${#sentrix_pos[@]}")!"
	exit 1
fi

##Find the .idat files
unknown_entries=()

for ((i=0;i<${#sentrix_id[@]};++i)); do
	#Store the concatenated name into GRN and RED
	sentrix_id_pos=${sentrix_id[i]}_${sentrix_pos[i]}
	
#	echo $sentrix_id_pos

	GRN=$sentrix_id_pos"_Grn.idat"
	RED=$sentrix_id_pos"_Red.idat"

 	#Make several subdirectories containing the Sentrix IDs if subdirectories are wanted
 	if [ ! -d "${sentrix_id[i]}" ]; then
 		mkdir ${sentrix_id[i]}  		
 	fi
 	cd ${sentrix_id[i]}
 
	#Find the files and copy them to the data directory	
  	if [[ ! -z `find "$source_dir" -type f -name $GRN` ]]; then
		if [ $verbose -eq 1 ]; then
			echo "Found $GRN" 
		fi
		find "$source_dir" -type f -name $GRN -exec cp {} . \;
	else
		if [ $verbose -eq 1 ]; then
			echo "Cannot find $GRN"
		fi
		unknown_entries+=$GRN
	fi

 	if [[ ! -z `find "$source_dir" -type f -name $RED` ]]; then
		if [ $verbose -eq 1 ]; then
			echo "Found $RED" 
		fi
		find "$source_dir" -type f -name $RED -exec cp {} . \;
	else
		if [ $verbose -eq 1 ]; then
			echo "Cannot find $RED"
		fi
		unknown_entries+=$RED
	fi
 
 	cd ..
done

if [ ${#unknown_entries[@]} -ne 0 ]; then
	echo "The following arrays were not be found:"
	for missing in "${unknown_entries[@]}"; do
		echo $missing
	done
fi

