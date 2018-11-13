#!/bin/sh

# This script computes the pairwise atlas fiber cluster distance

output_distance_folder=../NotGit/Projects/HCP-S500_one/atlas_cluster_distance

ATLAS=/data/lmi/software/ORG-atlases/ORG-Atlases-1.0/ORG-800FC-100HCP

dis_measure='fulllength_mean'  #dis_measure='endpoint_mean' # not implemented

percentage='0.2'

##
if [ ! -d $output_distance_folder ]; then
	mkdir $output_distance_folder
	mkdir $output_distance_folder/tracts_commissural
	mkdir $output_distance_folder/tracts_left_hemisphere
	mkdir $output_distance_folder/tracts_right_hemisphere
fi

output_c_npy=$output_distance_folder/tracts_commissural/pairdist_${dis_measure}_p${percentage}.npy
output_l_npy=$output_distance_folder/tracts_left_hemisphere/pairdist_${dis_measure}_p${percentage}.npy
output_r_npy=$output_distance_folder/tracts_right_hemisphere/pairdist_${dis_measure}_p${percentage}.npy

if [ ! -f $output_c_npy ]; then
	$1 bsub -q big-multi -n 20 \
		python wm_pairwise_cluster_distance.py $ATLAS/tracts_commissural $output_distance_folder/tracts_commissural/pairdist_${dis_measure}_p${percentage}.npy -perc_fbs $percentage -dis_measure ${dis_measure} -j 20
fi 

if [ ! -f $output_l_npy ]; then
	$1 bsub -q big-multi -n 20 \
		python wm_pairwise_cluster_distance.py $ATLAS/tracts_left_hemisphere $output_distance_folder/tracts_left_hemisphere/pairdist_${dis_measure}_p${percentage}.npy -perc_fbs $percentage -dis_measure ${dis_measure} -j 20
fi

if [ ! -f $output_r_npy ]; then
	$1 bsub -q big-multi -n 20 \
		python wm_pairwise_cluster_distance.py $ATLAS/tracts_right_hemisphere $output_distance_folder/tracts_right_hemisphere/pairdist_${dis_measure}_p${percentage}.npy -perc_fbs $percentage -dis_measure ${dis_measure} -j 20
fi
