#!/bin/sh

# This script computes tract measures such FA and num of fiber of subject-specific clusering results

txt_tract_measure_folder=../NotGit/Projects/HCP-S500_one/subject_cluster_measure

txt_c_tract_measure_folder=$txt_tract_measure_folder/tracts_commissural
txt_l_tract_measure_folder=$txt_tract_measure_folder/tracts_left_hemisphere
txt_r_tract_measure_folder=$txt_tract_measure_folder/tracts_right_hemisphere

output_c_mat=$txt_c_tract_measure_folder/all_matrix_features.mat
output_l_mat=$txt_l_tract_measure_folder/all_matrix_features.mat
output_r_mat=$txt_r_tract_measure_folder/all_matrix_features.mat

if [ ! -f $output_c_mat ]; then
	$1 bsub -q big -n 2 \
		"module add matlab/2015a; matlab -nodesktop -nosplash -r \"feat_txt2mat('$txt_c_tract_measure_folder'); exit;\""
fi

if [ ! -f $output_l_mat ]; then
	$1 bsub -q big -n 2 \
		"module add matlab/2015a; matlab -nodesktop -nosplash -r \"feat_txt2mat('$txt_l_tract_measure_folder'); exit;\""
fi

if [ ! -f $output_r_mat ]; then
	$1 bsub -q big -n 2 \
		"module add matlab/2015a; matlab -nodesktop -nosplash -r \"feat_txt2mat('$txt_r_tract_measure_folder'); exit;\""
fi
