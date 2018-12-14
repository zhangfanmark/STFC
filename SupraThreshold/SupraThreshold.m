function [ min_corrected_p, significance_threshold, true_max_STFC_size, true_suprathreshold_parcels, significant_STFCs, corrected_p_significant_STFCs ]...
           = SupraThreshold(feat_gp1, feat_gp2, pairwise_parcel_distances, primary_threshold_p_value, correction_significance_level, h_clique_size, flag_figure)

       
%% STFC statistics using real data
%  5. Identify suprathreshold parcels in the correctly labeled data (Section 2.4.1)
%  6. Extract all STFCs and compute their STFC sizes (Section 2.4.2)
% (As in Algorithm 1; Here we compute from the real data first, while in the paper we build the null distribution first.)

[true_max_STFC_size, true_p_per_parcel, true_all_STFCs, true_all_STFC_sizes] ...
    = SupraThreshold_transform(feat_gp1, feat_gp2, pairwise_parcel_distances, primary_threshold_p_value, h_clique_size);

true_suprathreshold_parcels = find(true_p_per_parcel < primary_threshold_p_value);

if isempty(true_suprathreshold_parcels) % No significante at all
    
    disp('== There are no suprathreshold parcels in the data.');
    
    min_corrected_p = [];
    significance_threshold = [];
    true_max_STFC_size = [];
    true_suprathreshold_parcels = [];
    significant_STFCs = [];
    corrected_p_significant_STFCs = [];
    
    return
end

%% STFC statistics using nonparametric permutation test
% 3. For each permutation run in [1, N] do
%    3.1. Randomly permute group labels of all subjects
%    3.2. Identify suprathreshold parcels from the permuted data (Section 2.4.1)
%    3.3. Extract all STFCs and record the maximal STFC size (Section 2.4.2)
% 4. Calculate the histogram of the maximal STFC size to produce the null distribution
% (As in Algorithm 1)

N_perms = 10000;

% Build the null distribution from permutation
null_distribution_max_STFC_size = [];
parfor i = 1:N_perms
    
    n_gp1 = size(feat_gp1, 1);
    n_gp2 = size(feat_gp2, 1);

    fake_gp1_indices = randperm(n_gp1+n_gp2, n_gp1);
    fake_gp2_indices = setdiff(1:n_gp1+n_gp2, fake_gp1_indices);

    feat_all = [feat_gp1; feat_gp2];

    fake_feat_gp1 = feat_all(fake_gp1_indices, :);
    fake_feat_gp2 = feat_all(fake_gp2_indices, :);

    fake_max_STFC_size = SupraThreshold_transform(fake_feat_gp1, fake_feat_gp2, pairwise_parcel_distances, primary_threshold_p_value, h_clique_size);
    
    null_distribution_max_STFC_size = [null_distribution_max_STFC_size fake_max_STFC_size];
end

% Compute significance threshold of STFC size that corresponds to the given significance level.
% As a result, an STFC size >= significance_threshold is significant.
sorted_null_distribution_max_STFC_size = sort(null_distribution_max_STFC_size);
significance_threshold = min(sorted_null_distribution_max_STFC_size);
for unique_max_STFC_size = unique(sorted_null_distribution_max_STFC_size)
    if (sum(null_distribution_max_STFC_size >= unique_max_STFC_size) + 1) / (N_perms+1) < correction_significance_level
        significance_threshold = unique_max_STFC_size;
        break
    end
end

% Corrected p value of the largest STFC, which should be the smallest p value.
% This is to see if there is at least one STFC with significance.
if significance_threshold < 2 || true_max_STFC_size < 2
    min_corrected_p = nan;
else
    min_corrected_p = (sum(null_distribution_max_STFC_size >= true_max_STFC_size) + 1) / (N_perms+1);
end

disp([' = Number of suprathreshold parcels: ', num2str(length(true_suprathreshold_parcels))]);
disp([' = Significance threshold          : ', num2str(significance_threshold)]);
disp([' = Maximal STFC size in real data  : ', num2str(true_max_STFC_size)]);
disp([' = Corrected p of the maximal STFC : ', num2str(min_corrected_p)]);

%% Compute a corrected p value for each signicant STFC.
% 7. for each STFC do
%    7.1 Locate its STFC size in the histogram of the maximal STFC size
%    7.2 Obtain number of permutations with the maximal STFC size larger than or equal to the size of STFC as N(s) 
%    7.3 Compute the corrected significance value as (N(s) + 1) / (N + 1)
% (Here we only compute corrected p values of significant STFCs, i.e. STFC size > significance_threshold)

if min_corrected_p <= correction_significance_level % At least one significant STFC
    disp(' ** Significance!!!  :) :)');
    significant_STFCs = true_all_STFCs(true_all_STFC_sizes >= significance_threshold);

    corrected_p_significant_STFCs = []; 
    for c_sig_idx = 1:length(significant_STFCs)
        size_of_one_significant_STFC = length(significant_STFCs{c_sig_idx});           
        corrected_p = (sum(null_distribution_max_STFC_size >= size_of_one_significant_STFC) + 1) / (N_perms+1);
        corrected_p_significant_STFCs = [corrected_p_significant_STFCs, corrected_p];

        disp(['  = STFC ' num2str(c_sig_idx) ' has ' num2str(size_of_one_significant_STFC) ' parcels (corr_p=' num2str(corrected_p) '): ' num2str(significant_STFCs{c_sig_idx})]);
    end
    
    % Plot the histogram of the maximal STFC size in permutation (see Figures 10.c and 11.c).
    if flag_figure
        figure; 

        edges = double(-1:max(null_distribution_max_STFC_size)) + 0.5;
        N_permutation_max_STFC_size = histcounts(null_distribution_max_STFC_size, edges); 

        N_permutation_max_STFC_size = N_permutation_max_STFC_size * 5;
        N_permutation_max_STFC_size = N_permutation_max_STFC_size(:);
        bar(edges(1:end-1)+0.5, N_permutation_max_STFC_size); hold on; 
        xlim([min(edges), max([edges true_max_STFC_size])])
        xlabel('Maximal STFC Size')
        ylabel('Occurrence Count')
        yL = get(gca,'YLim');

        l1 = line([significance_threshold significance_threshold], yL, 'Color','r', 'LineWidth', 2, 'LineStyle', '-');
        hold on; 

        for sig_c = 1:length(significant_STFCs)
            if length(significant_STFCs{sig_c}) == significance_threshold;
                offset = 0.2;
            else
                offset = 0;
            end
            l2 = line([length(significant_STFCs{sig_c})+offset, length(significant_STFCs{sig_c})+offset], yL, 'Color','m', 'LineWidth', 2, 'LineStyle', '--');
        end
        legend([l1, l2], {'Significance Threshold', 'Significant STFC'});
        set(gca, 'FontSize', 12, 'FontWeight', 'bold')
    end
    
    % Plot the comparison of features per identified parcel in each
    % significant STFC (see Figures 10.d, 11.d and 11.e).
    if flag_figure
        for c_sig_idx = 1:length(significant_STFCs)
            one_significant_cluster = significant_STFCs{c_sig_idx};

            feat_gp1_mean = nanmean(feat_gp1(:, one_significant_cluster), 1);
            feat_gp2_mean = nanmean(feat_gp2(:, one_significant_cluster), 1);

            [~, I] = sort(feat_gp2_mean);

            feat_gp1_std = nanstd(feat_gp1(:, one_significant_cluster), [], 1);
            feat_gp2_std = nanstd(feat_gp2(:, one_significant_cluster), [], 1);

            figure; 
            errorbar([1:length(one_significant_cluster)] - 0.15, feat_gp1_mean(I), feat_gp1_std(I), '*', 'LineWidth', 2);
            hold on;
            errorbar([1:length(one_significant_cluster)] + 0.15, feat_gp2_mean(I), feat_gp2_std(I), 'o' ,'LineWidth', 2);
            legend({'Group 1', 'Group 2'});
            hold on; 
            xL = get(gca,'XLim');
            line(xL, [0 0], 'Color','g', 'LineWidth', 2, 'LineStyle', '--');
            xlabel('Parcels with Significant Group Difference');
            ylabel('Feature')

            lim_up = max([feat_gp1_mean + feat_gp1_std feat_gp2_mean + feat_gp2_std]);
            lim_low = min([feat_gp1_mean - feat_gp1_std feat_gp2_mean - feat_gp2_std]);

            ylim([lim_low - 0.1, lim_up + 0.1])
            set(gca, 'FontSize', 12, 'FontWeight', 'bold');
            
        end
    end
else
    disp(' ** NO significance ... :( :(');
    significant_STFCs = [];
    corrected_p_significant_STFCs = {};
end
