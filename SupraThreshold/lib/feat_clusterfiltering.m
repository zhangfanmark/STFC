function [matrix_features, num_of_subjects_per_cluster] = feat_clusterfiltering(matrix_features, sub_threshold)

%disp(['<Filtering clusters accoring to NaN> num_of_nan < ' num2str(sub_threshold)]);

if sub_threshold > 0
    
    num_of_subjects_per_cluster = sum(~isnan(matrix_features));
    cluster_kept = num_of_subjects_per_cluster > sub_threshold;
    
elseif sub_threshold == -1
    
    sign_matrix = (matrix_features > 0) * 1;
    
    n_cluster = size(sign_matrix, 2);
    n_subject = size(sign_matrix, 1);
    for c_idx = 1:n_cluster
        x = sign_matrix(:, c_idx);
        if sum(x) > n_subject/2
            p(c_idx) = myBinomTest(sum(x), n_subject, 0.5, 'two') / 2;
        else
            p(c_idx) = 1;
        end
    end
    
    [corrected_p, ~] = bonf_holm(p, 0.05);
    cluster_kept = corrected_p < 0.05;
    
    if 0
        num_of_subjects_per_cluster = sum(~isnan(matrix_features));
        cluster_removed = corrected_p >= 0.05;
        figure; plot(num_of_subjects_per_cluster(cluster_kept));
        figure; plot(num_of_subjects_per_cluster(cluster_removed));
    end
    
end

num_of_subjects_per_cluster = sum(~isnan(matrix_features));

matrix_features(:, ~cluster_kept) = nan;
