function write_mrml_separated_parcels(atlas_folder, output_folder, kept_IDs, suffix)

atlas_c_folder = fullfile(atlas_folder, 'tracts_commissural');
atlas_l_folder = fullfile(atlas_folder, 'tracts_left_hemisphere');
atlas_r_folder = fullfile(atlas_folder, 'tracts_right_hemisphere');

vtp_list = dir(fullfile(atlas_c_folder, 'cluster*.vtp'));

k = length(vtp_list);

kept_IDs_c = kept_IDs(kept_IDs <= k);
kept_IDs_l = kept_IDs(kept_IDs > k & kept_IDs <= 2*k) - k;
kept_IDs_r = kept_IDs(kept_IDs > 2*k) - 2*k;

if ~isempty(kept_IDs_c)
    write_mrml_bilateral_parcels(atlas_c_folder, output_folder, kept_IDs_c, [suffix, '_comm_n', num2str(length(kept_IDs_c))]);
end
if ~isempty(kept_IDs_l)
    write_mrml_bilateral_parcels(atlas_l_folder, output_folder, kept_IDs_l, [suffix, '_left_n', num2str(length(kept_IDs_l))]);
end
if ~isempty(kept_IDs_r)
    write_mrml_bilateral_parcels(atlas_r_folder, output_folder, kept_IDs_r, [suffix, '_right_n', num2str(length(kept_IDs_r))]);
end
