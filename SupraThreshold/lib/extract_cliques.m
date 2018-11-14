function [all_clusters, all_cluster_sizes] = extract_cliques(neighbourhood_full, k_clique_size, significant_parcels)

if nargin > 2
    M = neighbourhood_full(significant_parcels, significant_parcels);
else
    M = neighbourhood_full;
end

%%
M = (M + M') > 0;

SP = sparse(M);
% h = view(biograph(SP));
[~, comp_per_parcel] = graphconncomp(SP, 'Weak', true);
% edges = double(0:max(comp_per_parcel)) + 0.5;
% N_per_comp = histcounts(comp_per_parcel, edges);

all_clusters = {};
for comp_idx = 1:max(comp_per_parcel)
    parcels_in_one_comp = find(comp_per_parcel == comp_idx);
    
    %disp(['Component:', num2str(comp_idx), ', size:', num2str(length(parcels_in_one_comp))]);
    
    if length(parcels_in_one_comp) == 1
        clique_communities = {1};
    elseif length(parcels_in_one_comp) == 2 % to identify size with 1
        clique_communities = {[1, 2]};
    else
        M_of_one_comp = M(parcels_in_one_comp, parcels_in_one_comp);
        % h = view(biograph(M_of_one_comp))
        [clique_communities,~,~] = k_clique(k_clique_size, M_of_one_comp);
    end
    
    if ~isempty(clique_communities)
        for cl_idx = 1:length(clique_communities)
            clique_communities{cl_idx} = parcels_in_one_comp(clique_communities{cl_idx});
        end
        all_clusters = {all_clusters{:}, clique_communities{:}};
    end
end

all_cluster_sizes = [];
for cluster_idx = 1:length(all_clusters)
    all_cluster_sizes = [all_cluster_sizes, length(all_clusters{cluster_idx})];
    
    if nargin > 2
        all_clusters{cluster_idx} = significant_parcels(all_clusters{cluster_idx});
    end
end

