import os
import argparse
import numpy
import glob

from joblib import Parallel, delayed

import whitematteranalysis as wma

#-----------------
# Parse arguments
#-----------------
parser = argparse.ArgumentParser(
    description="Compute pairwise fiber cluster distance.",
    epilog="Written by Fan Zhang",
    version='1.0')

parser.add_argument(
    'inputDirectory',
    help='A directory of fiber cluster files (vtk/vtp)')
parser.add_argument(
    'outputDistanceNPY',
    help='An output npy file to store the pairwise distances.')
parser.add_argument(
    '-perc_fbs', action="store", dest="percentageOfFibers", type=float, default=0.2,
    help='Percentage of fibers in each cluster per subject to be analyzed.')
parser.add_argument(
    '-dis_measure', action="store", dest="dis_measure", default='fulllength_mean',
    help='Cluster distance measure: fulllength_mean, fulllength_min, endpoint_mean, .etc.')
parser.add_argument(
    '-j', action="store", dest="numberOfJobs", type=int, default=4,
    help='Number of processors to use.')
parser.add_argument(
    '-verbose', action='store_true', dest="flag_verbose",
    help='Verbose. Run with -verbose for more text output.')

args = parser.parse_args()

if not os.path.isdir(args.inputDirectory):
    print "Error: Input directory", input_fclusters_dir, "does not exist."
    exit()

output_dir = os.path.dirname(args.outputDistanceNPY)
if not os.path.exists(output_dir):
    print "Output directory", output_dir, "does not exist, creating it."
    os.makedirs(output_dir)

def list_cluster_files(input_dir):
    # Find input files
    input_mask = "{0}/*cluster_*.vtk".format(input_dir)
    input_mask2 = "{0}/*cluster_*.vtp".format(input_dir)
    input_pd_fnames = glob.glob(input_mask) + glob.glob(input_mask2)
    input_pd_fnames = sorted(input_pd_fnames)
    return (input_pd_fnames)

def fcluster_to_fcluster_distance(pd_fcluster1_path, pd_fcluster2_path, threshold=0.0, verbose=False):
    ##  input Threshold (in mm) below which fiber points are considered in the same position.

    pd_fcluster1 = wma.io.read_polydata(pd_fcluster1_path)
    pd_fcluster2 = wma.io.read_polydata(pd_fcluster2_path)

    if pd_fcluster1.GetNumberOfLines() == 0 or pd_fcluster2.GetNumberOfLines() == 0:
        mean_dis = -1
    else:
        dis_cluster_to_cluster = wma.cluster._rectangular_distance_matrix(pd_fcluster1, pd_fcluster2, threshold,
                                                                            number_of_jobs=1, landmarks_n=None, landmarks_m=None,
                                                                            distance_method='Hausdorff',
                                                                            bilateral=True)

        mean_dis = numpy.mean(dis_cluster_to_cluster)

    return mean_dis

def pairwise_cluster_distance(input_fcluster_dir, num_jobs=1):

    print '[pairwise_cluster_distance] pairwise_cluster_distance computing.'

    pds_fcluster_paths = list_cluster_files(input_fcluster_dir)

    dis_fcluster_to_fcluster = list()
    for pd_fcluster1_path in pds_fcluster_paths:
        
            print os.path.split(pd_fcluster1_path)[1]

            dis_tmp = \
                Parallel(n_jobs=num_jobs, verbose=0, temp_folder='/data/lmi/projects/tmp_p')(
                    delayed(fcluster_to_fcluster_distance)(
                        pd_fcluster1_path, pd_fcluster2_path)
                    for pd_fcluster2_path in pds_fcluster_paths)

            dis_fcluster_to_fcluster.append(dis_tmp)

    dis_fcluster_to_fcluster = numpy.array(dis_fcluster_to_fcluster)

    tmp = dis_fcluster_to_fcluster
    print ''
    print 'Distance matrix: range', numpy.min(tmp), 'to', numpy.max(tmp), \
          ', shape:', tmp.shape, ', NaN #:', (numpy.isnan(tmp)).sum(), '/', tmp.shape[0] * tmp.shape[1]

    return dis_fcluster_to_fcluster

dis_fcluster_to_fcluster = pairwise_cluster_distance(args.inputDirectory, args.numberOfJobs)

numpy.save(args.outputDistanceNPY, dis_fcluster_to_fcluster)

print 'Done! Output is', args.outputDistanceNPY


