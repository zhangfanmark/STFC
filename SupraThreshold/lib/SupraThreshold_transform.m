function [ max_STFC_size, p_per_parcel, all_STFCs, all_STFC_sizes ] ...
            = SupraThreshold_transform(feat_gp1, feat_gp2, pairwise_parcel_distances, primary_threshold_p_value, h_clique_size)
        
        
%% Identify suprathreshold parcels 
[~, p_per_parcel] = ttest2(feat_gp1, feat_gp2, 'Tail', 'both');

suprathreshold_parcels = find(p_per_parcel < primary_threshold_p_value);

%% Extract all STFCs and record the maximal STFC size
if ~isempty(suprathreshold_parcels)
    neighbourhood_full = pairwise_parcel_distances > 0;
    
    [all_STFCs, all_STFC_sizes] = extract_cliques(neighbourhood_full, h_clique_size, suprathreshold_parcels);
    
    if ~isempty(all_STFC_sizes)
        max_STFC_size = max(all_STFC_sizes);
    else
        max_STFC_size = 0;
    end
else
    max_STFC_size = 0;
    all_STFCs = {};
    all_STFC_sizes = [];
end
