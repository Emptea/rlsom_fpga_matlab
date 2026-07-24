function sg = get_mat_data(folder, tp_num)
switch(tp_num)
    case {1,2}
        load(folder + "/sig_tp1_fd.mat")
        sg = tp1_fd;
    case 3
        load(folder + "/sig_tp2_fap.mat")
        sg = tp2_fap;
    case 4
        load(folder + "/sig_tp3_lou.mat")
        sg = tp3_lou;
    case 5
        load(folder + "/sig_tp4_sf_far.mat")
        load(folder + "/sig_tp4_sf_near.mat")
        sg = tp4_sf_far;
        sg(:,102:141, :) = tp4_sf_near;
end
