function [hemi_indices, comm_indices] = ut_get_parcel_location(parcel_location_txt)

M = tdfread(parcel_location_txt);

hemi_indices = [];
comm_indices = [];
for i = 1:size(M.Location_Label, 1)
    
    loc = M.Location_Label(i, :);
    
    if loc == 'h'
        hemi_indices = [hemi_indices, i];
    elseif loc == 'c'
        comm_indices = [comm_indices, i];
    else
        comm_indices = [comm_indices, i];
    end
end

