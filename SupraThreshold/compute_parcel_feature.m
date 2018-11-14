function [ feat_gp1, feat_gp2 ] = compute_parcel_feature(input_measure_folder, input_distance_folder, parcel_measure, target_feature)

%% Read input

% .mat files of measure matrices
measure_c_mat = fullfile(input_measure_folder, 'tracts_commissural', 'all_matrix_features.mat');
measure_l_mat = fullfile(input_measure_folder, 'tracts_left_hemisphere', 'all_matrix_features.mat');
measure_r_mat = fullfile(input_measure_folder, 'tracts_right_hemisphere', 'all_matrix_features.mat');

measure_c = load(measure_c_mat);
measure_l = load(measure_l_mat);
measure_r = load(measure_r_mat);

c_feat_matrix = measure_c.all_matrix_features.(parcel_measure);
l_feat_matrix = measure_l.all_matrix_features.(parcel_measure);
r_feat_matrix = measure_r.all_matrix_features.(parcel_measure);

% group label file 
group_label_txt = fullfile(input_measure_folder, 'subject_group.csv');
group_label_table = readtable(group_label_txt);
group_label = group_label_table.GROUP;

% parcel location file (commissural or hemispheric)
parcel_location_txt = fullfile(input_distance_folder, 'cluster_hemisphere_location.txt');

[hemi_indices, comm_indices] = ut_get_parcel_location(parcel_location_txt);

%% Get feature matrix

n_parcel = size(c_feat_matrix, 2);

c_feat_matrix(:, setdiff(1:n_parcel, comm_indices)) = nan;
l_feat_matrix(:, setdiff(1:n_parcel, hemi_indices)) = nan;
r_feat_matrix(:, setdiff(1:n_parcel, hemi_indices)) = nan;

if strcmp(target_feature, 'Whole') || strcmp(target_feature, 'Left') || strcmp(target_feature, 'Right') || strcmp(target_feature, 'Comm')
    
    if strcmp(target_feature, 'Whole')
        feat_matrix = [c_feat_matrix l_feat_matrix r_feat_matrix];
    elseif strcmp(target_feature, 'Comm')
        feat_matrix = c_feat_matrix;
    elseif strcmp(target_feature, 'Left')
        feat_matrix = l_feat_matrix;
    elseif strcmp(target_feature, 'Right')
        feat_matrix = r_feat_matrix;
    end
        
%     if ~isempty(strfind(parcel_measure, 'Num_Fibers'))
%         feat_matrix(feat_matrix == 0) = nan;
%     end
    feat_matrix = feat_clusterfiltering(feat_matrix, -1);
    
elseif strcmp(target_feature, 'LI')
    
    feat_matrix = (r_feat_matrix - l_feat_matrix) ./ (r_feat_matrix + l_feat_matrix);
    
end

feat_gp1 = feat_matrix(group_label==1, :);
feat_gp2 = feat_matrix(group_label==2, :);
