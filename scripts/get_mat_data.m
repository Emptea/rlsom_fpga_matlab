function sg = get_mat_data(folder, tp_num, range_gate)
arguments
    folder string
    tp_num double
    range_gate double = 0
end
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
    case 6
        load(folder + "/sig_tp5_ddr_far.mat")
        load(folder + "/sig_tp5_ddr_near.mat")
        if (range_gate < 101)
            sg = permute(tp5_ddr_far(:, range_gate + 1, :, :), [1 3 4 2]);
        else
            sg = permute(tp5_ddr_near(:, range_gate + 1 - 101, :, :), [1 3 4 2]);
        end
    case 7
        load(folder + "/sig_tp6_kn_far.mat")
        
        if range_gate < 101
            load(folder + "/sig_tp6_kn_far.mat")
            sg = permute(tp6_kn_far(:, range_gate + 1, :, :), [1 3 4 2]);
        else
            load(folder + "/sig_tp6_kn_near.mat")
            sg = permute(tp6_kn_near(:, range_gate + 1 - 101, :, :), [1 3 4 2]);
        end
    case 8
        load(folder + "/sig_tp7_ad_far.mat")
        load(folder + "/sig_tp7_ad_near.mat")
        sg = tp7_ad_far;
        sg(102:141, :) = tp7_ad_near;
    case 9
        
end
