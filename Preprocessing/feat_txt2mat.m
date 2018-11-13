function [all_matrix_features, all_matrix_features_path] = feat_txt2mat(txt_folder_path)

all_matrix_features_path = [txt_folder_path filesep 'all_matrix_features.mat'];
if exist(all_matrix_features_path, 'file')
    load([txt_folder_path filesep 'all_matrix_features.mat']);
else
    txt_list = dir([txt_folder_path filesep '*.csv' ]);
    fprintf('Transfering TXT to MAT: 000');
    for t = 1:length(txt_list)

        fprintf('\b\b\b');
        fprintf('%s%%', num2str(round(t/length(txt_list)*100), '%02d'))
    
        txt_path = [txt_folder_path filesep txt_list(t).name];
        txt_data = importdata(txt_path);

        clear measures;
        for i = 2:size(txt_data.textdata, 1)
            vtp_path = char(txt_data.textdata(i, 1)); 
            measure_per_cluster = [];
            measure_per_cluster.(strtrim(char(txt_data.textdata(1, 1)))) = vtp_path;
            for j = 2:size(txt_data.textdata, 2)
                field = strrep(strtrim(char(txt_data.textdata(1, j))), '.', '_');
                measure_per_cluster.(field) = txt_data.data(i-1, j-1);
            end

            cluster_number = str2double(vtp_path(end-9:end-5));
            if isnan(cluster_number)
                continue;
            end
            measures(cluster_number) = measure_per_cluster;      
        end
        save([txt_folder_path filesep strrep(txt_list(t).name, '.csv', '.mat')], 'measures');
    end
    fprintf('\n');

    % all feature matrix initialization
    n_data = length(txt_list);
    K = length(measures);
    features = fields(measures);
    features = features(2:end); % exclude 'name'
    for f = 1:length(features)
        all_matrix_features.(features{f}) = zeros(n_data, K);
    end

    mat_list = dir([txt_folder_path filesep '*.mat']);
    fprintf('Intergating into all_matrix_features: 000');
    for i = 1:length(mat_list)
        
        fprintf('\b\b\b');
        fprintf('%s%%', num2str(round(i/length(txt_list)*100), '%02d'))
        
        load([txt_folder_path filesep mat_list(i).name]);
        for f = 1:length(features)
            feature_name = features{f};
            feat_len = length(measures);
            vec_feature = ones(1, feat_len) * -1;

            for i_v_f = 1:feat_len
                v_f = measures(i_v_f).(feature_name);
                if ~isempty(v_f)
                    vec_feature(i_v_f) = v_f;
                end
            end

            vec_feature(vec_feature==-1) = NaN;
            if strcmp(feature_name, 'Num_Fibers')
                vec_feature(isnan(vec_feature)) = 0;
            end

            temp_matrix = all_matrix_features.(feature_name);
            temp_matrix(i, :) = vec_feature;
            all_matrix_features.(feature_name) = temp_matrix;
        end
    end
    fprintf('\n');

    all_matrix_features_path = [txt_folder_path filesep 'all_matrix_features.mat'];
    save(all_matrix_features_path, 'all_matrix_features');
end

num_of_subjects_per_cluster = sum(all_matrix_features.Num_Fibers > 0);
num_of_subjects_per_cluster_sort = sort(num_of_subjects_per_cluster);
save([txt_folder_path filesep 'num_of_subjects_per_cluster.mat'], 'num_of_subjects_per_cluster', 'num_of_subjects_per_cluster_sort');

