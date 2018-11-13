#!/bin/sh

# This script separates the atlas cluster into hemispheres.

ATLAS=/data/lmi/software/ORG-atlases/ORG-Atlases-1.0/ORG-800FC-100HCP
 
$1 bsub -q big -n 2 \
wm_separate_clusters_by_hemisphere.py $ATLAS $ATLAS -atlasMRML $ATLAS/clustered_tracts_display_100_percent.mrml -clusterLocationFile $ATLAS/cluster_hemisphere_location.txt