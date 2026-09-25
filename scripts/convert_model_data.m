function convert_model_data(src_folder, model_folder, tp_num)

if ~exist(model_folder, "dir")
    mkdir(model_folder);
end

far_field = 41:141;
near_field = 148:187;

switch tp_num
    
    case tp.TP_BYPASS
        model = load_data(src_folder, "sig_tp1_fd.mat");
        
    case tp.TP_CUT
        model = load_data(src_folder, "sig_tp1_fd.mat");
        model = [model(:,far_field,:), model(:,1:20,:)*0, model(:,near_field,:), model(:,1:3,:)*0];
        
    case tp.TP_FAPCH
        model = load_data(src_folder, "sig_tp2_fap.mat");
        model = [model(:,far_field,:), model(:,1:20,:)*0, model(:,near_field,:), model(:,1:3,:)*0];
        
    case tp.TP_LOU
        model = load_data(src_folder, "sig_tp3_lou.mat");
        model = [model(:,1:101,:), model(:,1:20,:)*0, model(:,102:end,:), model(:,1:3,:)*0];
        
    case tp.TP_SF
        far  = load_data(src_folder, "sig_tp4_sf_far.mat");
        near = load_data(src_folder, "sig_tp4_sf_near.mat");
        model = [far, near];
        
    case tp.TP_DDR
        far  = load_data(src_folder, "sig_tp5_ddr_far.mat");
        near = load_data(src_folder, "sig_tp5_ddr_near.mat");
        model = [far, near];
        model = model(:,:,:,2:end);
        
    case tp.TP_FFT
        near = load_data(src_folder, "sig_tp6_kn_near.mat");
        far  = load_data(src_folder, "sig_tp6_kn_far.mat");
        model = [far, near];
        model = model(:,:,:,2:end);
        
    case tp.TP_MAX
        % TODO
        far  = load_data(src_folder, "sig_tp7_ad_far.mat");
        near = load_data(src_folder, "sig_tp7_ad_near.mat");
        model = [far; near];
        model = model(:,2:end);
        
    case tp.TP_FIND
        return;
        % far  = load_data(src_folder, "sig_tp8_apu_far.mat");
        % near = load_data(src_folder, "sig_tp8_apu_near.mat");
        % model = [far; near];
        
    case tp.TP_RANK
        far  = load_data(src_folder, "sig_tp9_rank_far.mat");
        near = load_data(src_folder, "sig_tp9_rank_near.mat");
        model = [far; near];
        model = model(:,2:end);

    case tp.TP_APU
        far  = load_data(src_folder, "sig_tp8_apu_far.mat");
        near = load_data(src_folder, "sig_tp8_apu_near.mat");
        model = [far; near];
        model = model(:,2:end);
        
    case tp.TP_FAPCH_COEFFS
        model = load_data(src_folder, "sig_tp12_fapch_coeffs.mat");
        
    case tp.TP_WEIGHT_OUT
        far  = load_data(src_folder, "sig_tp5_ddr_far.mat");
        near = load_data(src_folder, "sig_tp5_ddr_near.mat");
        model = [far, near];
        model = model(:,:,:,2:end);
        model = calc_weight(model);

    case tp.TP_MTI
        model  = load_data(src_folder, "sig_tp14_mti.mat");
        
    otherwise
        error("Unsupported test point: TP%d", double(tp_num));
end

%% Сохраняем
var_name = "model_" + tp_num.to_string();
filename = fullfile(model_folder, var_name + ".mat");

S = struct();
S.(var_name) = model;

save(filename, "-struct", "S");

fprintf("✓ Created: %s\n", filename);

end


function data = load_data(folder, filename)

S = load(fullfile(folder, filename));

names = fieldnames(S);

assert(numel(names) == 1, ...
    "Expected one variable in %s", filename);

data = S.(names{1});

end