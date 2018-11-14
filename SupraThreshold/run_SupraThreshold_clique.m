function result_folder = run_SupraThreshold_clique(input_distance_folder, input_measure_folder, parcel_distance, parcel_measure, target_feature, T_local_neighbors, h_clique_size, output_folder, flag_figure)

% feature  : RTAP1_Mean, RTOP1_Mean, RTPP1_Mean
% measure  : LI, Whole
% distance : min mean

%% Print log message
disp('===================================================')
disp(['- Parcel measure  : ', parcel_measure]);
disp(['- Parcel distance : ', parcel_distance]);
disp(['- Target feature  : ', target_feature]);
disp(['- STFC paramters  : T (local neighbors) ', num2str(T_local_neighbors), '; h (clique size) ' , num2str(h_clique_size)]);

%% Setup output

result_folder = fullfile(output_folder, 'STFC_output', ['STFC-', parcel_measure, '-', target_feature, '-', parcel_distance], ['T' num2str(T_local_neighbors) '_h' num2str(h_clique_size)]);
if ~exist(result_folder, 'dir')
    mkdir(result_folder)
end

result_mat = fullfile(result_folder, 'results.mat');
%% STFC statistics

% Primary significance threshold to define suprathreshold parcels.
primary_threshold_p_value = 0.05;

% Significance level in STFC multiple comparison correction.
correction_significance_level = 0.05;

if exist(result_mat, 'file') == 2 
    disp('** Load previously computed STFC statistics.');
    load(result_mat);
    
else
    disp('** Compute STFC statistics.');
    
    % Feature
    [feat_gp1, feat_gp2] = compute_parcel_feature(input_measure_folder, input_distance_folder, parcel_measure, target_feature); 
    
    % Parcel distance
    pairwise_parcel_distances = construct_parcel_neighborhood(input_distance_folder, parcel_distance, target_feature, T_local_neighbors);

    % STFC statistics
    [min_corrected_p, significance_threshold, true_max_STFC_size, true_suprathreshold_parcels, significant_STFCs, corrected_p_significant_STFCs] ...
     = SupraThreshold(feat_gp1, feat_gp2, pairwise_parcel_distances, primary_threshold_p_value, correction_significance_level, h_clique_size, flag_figure);
    
    STFC.primary_threshold_p_value = primary_threshold_p_value;
    STFC.correction_significance_level = 0.05;
    STFC.min_corrected_p = min_corrected_p;
    STFC.significance_threshold = significance_threshold;
    STFC.true_max_STFC_size = true_max_STFC_size;
    STFC.true_suprathreshold_parcels = true_suprathreshold_parcels;
    STFC.significant_STFCs = significant_STFCs;
    STFC.corrected_p_significant_STFCs = corrected_p_significant_STFCs;
 
    save(result_mat, 'STFC');
end

w = what(result_folder);
disp('** Results can be found in: ');
disp(['  ', w.path]);
