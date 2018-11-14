function pairwise_parcel_distances = local_adaptive_indirect_connection(pairwise_parcel_distances, T_local_neighbors, remove_neighbors_not_connected)


%% 
% For each parcel, T+1 candidate neighbors (including itself) are kept.
neighbor_mask = zeros(size(pairwise_parcel_distances));
for p_idx = 1:size(pairwise_parcel_distances, 2)
    neighbor_distances_one_parcel = pairwise_parcel_distances(p_idx, :);
    [Y, I] = sort(neighbor_distances_one_parcel);
    
    kept_neighbors = I(1:T_local_neighbors+1); 
    kept_neighbors = kept_neighbors(~isnan(Y(1:T_local_neighbors+1)));
    
    % Note: Here, we start from index 1 (including the parcel iteself), in
    % case there could be a neighboring parcel has a distance lower to
    % itself. This should not happen in theory, but if there are few fibers in
    % the parcel too far away from the remaining but very close to another parcel.
    
    neighbor_mask(p_idx, kept_neighbors) = 1;
end

%%
% Locally adaptive parcel neighborhood construction.
% For each parcel, its candidate neighbors needs to be weakly connected to
% form a neighborhood.
if strcmp(remove_neighbors_not_connected, 'remove')
    
    neighbor_mask_new = zeros(size(pairwise_parcel_distances));
    for p_idx = 1:size(pairwise_parcel_distances, 2)     
        neighbors_of_one_parcel = setdiff(find(neighbor_mask(p_idx, :) ==1), p_idx);

        if length(neighbors_of_one_parcel) == T_local_neighbors 
            % Here, parcels have candidate neighbors fewer than T are excluded 
            % because we consider it neighbors need to form a weakly connected 
            % graph with n=T. But, such parcels can neighbors of other parcels. 
            
            neighborhood = neighbor_mask(neighbors_of_one_parcel, neighbors_of_one_parcel);

            SP = sparse(neighborhood);
            % h = view(biograph(SP));
            [~, connected_components] = graphconncomp(SP, 'Weak', true);

            edges = double(0:max(connected_components)) + 0.5;
            N_per_neighborhood = histcounts(connected_components, edges);

            max_neig_size = max(N_per_neighborhood); % The size of the largest connected component

            if max_neig_size >= T_local_neighbors % Should we need >?
                for n_idx = find(N_per_neighborhood == max_neig_size)
                    neig = neighbors_of_one_parcel(connected_components == n_idx);
                    neighbor_mask_new(p_idx, neig) = 1;
                end
            end
        end
        neighbor_mask_new(p_idx, p_idx) = 1;
    end
    neighbor_mask = neighbor_mask_new;
end

%%
pairwise_parcel_distances = neighbor_mask .* pairwise_parcel_distances;
pairwise_parcel_distances(pairwise_parcel_distances == 0) = nan;
