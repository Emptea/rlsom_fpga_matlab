function save_for_model(sg, tp_num)
far_field = 1:101;
near_field = 102:141;
switch tp_num
    case tp.TP_BYPASS
        tp1_fd = sg;
        save("sig_tp1_fd.mat", "tp1_fd");
    case tp.TP_FAPCH
        tp2_fap = sg;
        save("sig_tp2_fap.mat", "tp2_fap");
    case tp.TP_LOU
        tp3_lou = sg(:,[far_field, near_field+20],:);
        save("sig_tp3_lou.mat", "tp3_lou");
    case tp.TP_FFT
        tp5_kn_far = sg(:,far_field,:);
        save("sig_tp5_kn_far.mat", "tp5_kn_far");
        tp5_kn_near = sg(:,near_field,:);
        save("sig_tp5_kn_far.mat", "tp5_kn_near");
    otherwise
        return;
end

end