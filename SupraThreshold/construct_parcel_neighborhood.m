function [ pairwise_parcel_distances ] = construct_parcel_neighborhood(input_distance_folder, parcel_distance, target_feature, T_local_neighbors)

% parcel_distance : fulllength_mean, fulllength_min, endpoint_mean
% target_feature : Whole, Commissural, LI, Left, Right

%% Read input

% .npy files to the pairwise parcel distance matrices
dist_c_npy = fullfile(input_distance_folder, 'tracts_commissural', ['pairdist_', parcel_distance,'_p0.2.npy']);
dist_l_npy = fullfile(input_distance_folder, 'tracts_left_hemisphere', ['pairdist_', parcel_distance,'_p0.2.npy']);
dist_r_npy = fullfile(input_distance_folder, 'tracts_right_hemisphere', ['pairdist_', parcel_distance,'_p0.2.npy']);

dist_c = readNPY(dist_c_npy);
dist_l = readNPY(dist_l_npy);
dist_r = readNPY(dist_r_npy);

dist_c(dist_c < 0) = nan;
dist_l(dist_l < 0) = nan;
dist_r(dist_r < 0) = nan;

% parcel location file (commissural or hemispheric)
parcel_location_txt = fullfile(input_distance_folder, 'cluster_hemisphere_location.txt');

[hemi_indices, comm_indices] = ut_get_parcel_location(parcel_location_txt);

%% Get pairwise distance matrix

if strcmp(target_feature, 'LI') || strcmp(target_feature, 'Left') || strcmp(target_feature, 'Right') % The number of parcels -> n
    
    if strcmp(target_feature, 'LI') % the mean of Left and Right distances
        pairwise_parcel_distances = (dist_l + dist_r) ./ 2; % if either distance is nan, the mean distance will be nan.
    elseif strcmp(target_feature, 'Left')
        pairwise_parcel_distances = dist_l; 
    elseif strcmp(target_feature, 'Right')
        pairwise_parcel_distances = dist_r; 
    end
    
    % This is to regulate that only parcels in the same hemishphere have
    % non-nan distances. In this way, parcels across hemispheres will not
    % form any STFCs.
    n_parcel = size(pairwise_parcel_distances, 1);
    
    pairwise_parcel_distances(setdiff(1:n_parcel, hemi_indices), :) = nan;
    pairwise_parcel_distances(:, setdiff(1:n_parcel, hemi_indices)) = nan;

elseif strcmp(target_feature, 'Comm')  % The number of parcels -> n
    
    pairwise_parcel_distances = dist_c;
    
    n_parcel = size(pairwise_parcel_distances, 1);
    
    % This is to regulate that only commissural parcels have non-nan distances. 
    % In this way, hemispheric parcels will not form any STFCs.
    pairwise_parcel_distances(setdiff(1:n_parcel, comm_indices), :) = nan;
    pairwise_parcel_distances(:, setdiff(1:n_parcel, comm_indices)) = nan;
    
elseif strcmp(target_feature, 'Whole') % The number of parcels -> 3 * n

    n_parcel = size(dist_c, 1);
    
    pairwise_parcel_distances = [];
    pairwise_parcel_distances(1:n_parcel, 1:n_parcel) = dist_c;
    pairwise_parcel_distances(n_parcel+1:2*n_parcel, n_parcel+1:2*n_parcel) = dist_l;
    pairwise_parcel_distances(2*n_parcel+1:3*n_parcel, 2*n_parcel+1:3*n_parcel) = dist_r;
    
    % As in the above processing, only parcels in the same hemisphere or
    % commissural parcels will form STFCs.
    pairwise_parcel_distances(setdiff(1:n_parcel, comm_indices), :) = nan;
    pairwise_parcel_distances(:, setdiff(1:n_parcel, comm_indices)) = nan;
    
    pairwise_parcel_distances(setdiff(1:n_parcel, hemi_indices) + n_parcel, :) = nan;
    pairwise_parcel_distances(:, setdiff(1:n_parcel, hemi_indices) + n_parcel) = nan;
    
    pairwise_parcel_distances(setdiff(1:n_parcel, hemi_indices) + n_parcel*2, :) = nan;
    pairwise_parcel_distances(:, setdiff(1:n_parcel, hemi_indices) + n_parcel*2) = nan;
    
end

% Note: If using our provided ORG atlas with clearly defined parcel
% location, the above processing for regulating STFC formation will not be
% run. But, using a study-specific atlas, there might be fibers
% mis-separated. For example, a left-hemisphere fiber is classified into
% commissural 

pairwise_parcel_distances(pairwise_parcel_distances <= 0) = nan;
pairwise_parcel_distances = sqrt(pairwise_parcel_distances);

%% WM parcel neighborhood construction
% 2. Build parcel neighborhood graph from all WM parcels (Section 2.3)
% (As in Algorithm 1)
% 
% Each parcel has the same number of local neighbors: 
%  - T_local_neighbors: T = 4 is suggested in the paper given a study-specific 
%    white matter atlas with 800 parcels. But, this parameter needs to be adjusted 
%    based on the atlas used in a study. See Table 1 in the paper for parameter tunning.
% 
% Use 'remove' to remove the parcels that are not connected to others.

remove_neighbors_not_connected = 'remove';
pairwise_parcel_distances = local_adaptive_indirect_connection(pairwise_parcel_distances, T_local_neighbors, remove_neighbors_not_connected);


