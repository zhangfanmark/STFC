#!/bin/sh

# This script computes tract measures such FA and num of fiber of subject-specific clusering results

output_tract_measure_folder=../NotGit/Projects/HCP-S500_one/subject_cluster_measure

input_subject_base_folder=/data/lmi/projects/HCP/Tractography/S500_one/clusters_l40_k0800_f10k/cluster_atlas_01_00002_remove_outliers

subject_list=../NotGit/Projects/HCP-S500_one/S500_one_100_SubjectsList.txt

SlicerCLI=/data/lmi/software/Slicer/Slicer_161209_fca1f0c/ExtensionsIndex_build/SlicerDMRI-build/inner-build/lib/Slicer-4.7/cli-modules/FiberTractMeasurements

##
if [ ! -d $output_tract_measure_folder ]; then
	mkdir $output_tract_measure_folder
	mkdir $output_tract_measure_folder/tracts_commissural
	mkdir $output_tract_measure_folder/tracts_left_hemisphere
	mkdir $output_tract_measure_folder/tracts_right_hemisphere
fi

while read sub_id ; 
do
	echo 'Subject:' $sub_id
	
	subject_fc_c_folder=${input_subject_base_folder}/${sub_id}*/tracts_commissural
	subject_fc_l_folder=${input_subject_base_folder}/${sub_id}*/tracts_left_hemisphere
	subject_fc_r_folder=${input_subject_base_folder}/${sub_id}*/tracts_right_hemisphere

	# compute distance
	output_c_csv=$output_tract_measure_folder/tracts_commissural/${sub_id}.csv
	output_l_csv=$output_tract_measure_folder/tracts_left_hemisphere/${sub_id}.csv
	output_r_csv=$output_tract_measure_folder/tracts_right_hemisphere/${sub_id}.csv

	if [ ! -f $output_c_csv ]; then
		$1 bsub -q medium -n 1 -e $output_tract_measure_folder/e.log -o $output_tract_measure_folder/o.log \
			$SlicerCLI --inputtype Fibers_File_Folder --format Column_Hierarchy --separator Comma --inputdirectory $subject_fc_c_folder --outputfile $output_c_csv 
	fi

	if [ ! -f $output_l_csv ]; then
		$1 bsub -q medium -n 1 -e $output_tract_measure_folder/e.log -o $output_tract_measure_folder/o.log \
			$SlicerCLI --inputtype Fibers_File_Folder --format Column_Hierarchy --separator Comma --inputdirectory $subject_fc_l_folder --outputfile $output_l_csv 
	fi

	if [ ! -f $output_r_csv ]; then
		$1 bsub -q medium -n 1 -e $output_tract_measure_folder/e.log -o $output_tract_measure_folder/o.log \
			$SlicerCLI --inputtype Fibers_File_Folder --format Column_Hierarchy --separator Comma --inputdirectory $subject_fc_r_folder --outputfile $output_r_csv 
	fi
	
done <$subject_list
