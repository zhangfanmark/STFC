function view_SupraThreshold_results(result_folder, atlas_folder, target_feature)

%% Load STFC results

result_mat = fullfile(result_folder, 'results.mat');
r = load(result_mat);

%%

if exist(result_folder,'dir')
    delete(fullfile(result_folder, '*.mrml'));
end

if strcmp(target_feature, 'LI')
    write_mrml_bilateral_parcels(atlas_folder, result_folder, r.true_suprathreshold_parcels, ['suprathreshold_parcels_n', num2str(length(r.true_suprathreshold_parcels))]);

elseif strcmp(target_feature, 'Whole')
    write_mrml_separated_parcels(atlas_folder, result_folder, r.true_suprathreshold_parcels, 'suprathreshold_parcels');

end

for c_all = 1:length(r.significant_STFCs)
    parcels_in_significant_STFC = r.significant_STFCs{c_all};
    
    if strcmp(target_feature, 'LI')
        write_mrml_bilateral_parcels(atlas_folder, result_folder, parcels_in_significant_STFC, ['STFC_', num2str(c_all), '_n', num2str(length(parcels_in_significant_STFC))]);
    
    elseif strcmp(target_feature, 'Whole')
        write_mrml_separated_parcels(atlas_folder, result_folder, parcels_in_significant_STFC, ['STFC_', num2str(c_all)]);
        
    end
end

