close all
date = "2026-09-14";
date = string(datetime('today', 'Format', 'yyyy-MM-dd'));
folder_basename = "data/";
tp_num = 1; % ADC test point
range_gate = 47;
pulse_num = 50; % pulse num to plot
model_folder = folder_basename + "/2026-09-10/sig";
out_folder = folder_basename + date + "/";
far_field = 41:141;
near_field = 148:187;
hdr_sz = 6;
hdr = 1:hdr_sz;
noise_level = 40;
n_ch = 8;

if tp_num > 7
    ch = 0;
    n_ch = 1;
end
%%
if tp_num > 7
    launch_ip_comm_test(tp_num, ch, range_gate, 250, "adc_1000_packets.txt");
else
    for ch = 0:7
        launch_ip_comm_test(tp_num, ch, range_gate, 20, "adc_1000_packets.txt");
    end
end
get_board_data(folder_basename + date + "/", "out");
%%
clear sg
if tp_num > 7 
    ch = 0;
    hexname = out_folder +"/out_tp" + tp_num +"_ch" + ch + "_rg" + range_gate + ".hex";
    sg = fpga_txt2mat_for_ch(hexname, ch, range_gate);
    disp(sg(ch+1, hdr_sz, 1))
else
    for ch = 0:7
        try
            hexname = out_folder +"/out_tp" + tp_num +"_ch" + ch + "_rg" + range_gate + ".hex";
            sg(ch+1, :, :) = fpga_txt2mat_for_ch(hexname, ch, range_gate);
            disp(sg(ch+1, hdr_sz, 1))
        catch
            disp("Found no file for channel " + ch)
        end
    end
end

if tp_num ==6
    % check_sg = permute(model_sg(:,range_gate - 20,:,1:(size(sg,3)+1)), [1 3 4 2]);

    for ch = 0:7
        try
            hexname = out_folder +"/out_tp5_ch" + ch + "_rg" + range_gate + ".hex";
            tp5_sg(ch+1, :, :) = fpga_txt2mat_for_ch(hexname, ch, range_gate);
            disp(sg(ch+1, hdr_sz, 1))
        catch
            disp("Found no file for channel " + ch)
        end
    end
    check_sg = tp5_sg(:, hdr_sz+range_gate+1, :);
    check_sg = permute(check_sg, [1 3 2]);
    % check_sg = reshape(check_sg, 8,20,[]);
elseif tp_num == 9
    try
        hexname = out_folder +"/out_tp8_ch0_rg" + range_gate + ".hex";
        tp8_sg = fpga_txt2mat_for_ch(hexname, 0, range_gate);
        disp(sg(hdr_sz, 1))
    catch
        disp("Found no file for channel " + ch)
    end
    i = size(tp8_sg,2);
    M = 26;
    check_sg = tp8_sg(hdr_sz+1:end, [i-M-1, i-M, i-1, i, i-M/2])';
    check_sg = check_sg(:);
elseif tp_num > 7
    model_sg = get_mat_data(model_folder, tp_num, range_gate);
    check_sg = model_sg(:,1:size(sg,2));
else
    model_sg = get_mat_data(model_folder, tp_num, range_gate);
    check_sg = [model_sg(:,far_field, 1:size(sg,3)), zeros(8,20,size(sg,3)), ...
        model_sg(:,near_field, 1:size(sg,3)), zeros(8,3,size(sg,3))];
end



input_sg = get_mat_data(model_folder, 1);
input_sg = input_sg(:,:,1:size(sg,3));
out_sg = zeros(size(check_sg));
% TODO: написать через case
if tp_num == 1
    out_sg = sg(:,hdr_sz+1:end,:);
% elseif tp_num == 2 || tp_num == 3
%     out_sg(:,far_field, :) = sg(:,hdr_sz + 1:hdr_sz + 101,:);
%     out_sg(:, near_field, :) = sg(:,hdr_sz + 20 + 1 + 101:end-3,:);
elseif tp_num == 6
    out_sg = sg(:,hdr_sz+1:end,end);
    check_sg = check_sg(:,end-511:end);
elseif tp_num == 7
    out_sg = abs(sg(:,hdr_sz+1:end,:));
    check_sg = abs(check_sg);
elseif tp_num > 7
    out_sg = sg(hdr_sz+1:end, :);
elseif tp_num < 5
    out_sg = sg(:,[hdr_sz+1:end],:);
else    
    error("tp_num unknown");
end
%% Matlab аналог модели до СФ (на ЛОУ 1 канал матлаб кода и модели не совпадает по какой-то причине)
% phases = paramRLSmini.beamFormAng;
% p = phaseDelay();
% p.N = 8;
% p.freq = paramRLSmini.freq;
% p.stp = paramRLSmini.lambda/2;
% p.prop1 = 'Обработка';
% 
% sg_gen_far = txLFM();
% sg_gen_far.sPeriod = paramRLSmini.sampleTime;
% sg_gen_far.freqDev = paramRLSmini.sampleFreq;
% sg_gen_far.prop1 = 'Дальняя зона';
% 
% sg_gen_near = txLFM();
% sg_gen_near.sPeriod = paramRLSmini.sampleTime;
% sg_gen_near.freqDev = paramRLSmini.sampleFreq;
% sg_gen_near.prop1 = 'Ближняя зона';
% bf = beamformer('param_struct', paramRLSmini);
% 
% for i = 1:size(sg,3)
%     [fap_sg(:,:,i), Y, X, K] = phAutoTune(input_sg(:,:,i), 1e-3);
%     for ch = 1:8
%         d(ch, :) = p(phases(ch));
%         [sFbuf(ch, :),sNbuf(ch, :)] = bf(d(ch,:),fap_sg(:,:,i));
% 
%         txFSig = sg_gen_far();
%         sfFout(ch,:) = matchedFilter(txFSig, sFbuf(ch,:));
%         txNSig = sg_gen_near();
%         sfNout(ch,:) = matchedFilter(txNSig, sNbuf(ch,:));
%     end
% 
%     if (tp_num == 3)
%         check_sg(:,1:101,i) = sFbuf;
%         check_sg(:,102:141,i) = sNbuf;
%     elseif (tp_num == 4)
%         check_sg(:,1:101,i) = sfFout;
%         check_sg(:,102:141,i) = sfNout;
%     end
% end
% %%
% figure; plot_complex(reshape(check_sg, n_ch, [])')
% subplot(2,1,1); title("Whole signal from model")
% legend("channel " + num2str([0:n_ch - 1]'))
% subplot(2,1,2)
% legend("channel " + num2str([0:n_ch - 1]'))
% %%
% figure; plot_complex(reshape(out_sg, n_ch, [])')
% subplot(2,1,1); title("Whole signal from board")
% legend("channel " + num2str([0:n_ch - 1]'))
% subplot(2,1,2)
% legend("channel " + num2str([0:n_ch - 1]'))
%%
if tp_num == 7
    figure; plot(check_sg(:, :,pulse_num)')
    legend("channel " + num2str([0:n_ch - 1]'))
    title("Signal from model pulse num " + pulse_num)
elseif tp_num == 9
    figure; plot(check_sg)
    legend("channel " + num2str([0:n_ch - 1]'))
    title("Signal from model pulse num " + pulse_num)
elseif tp_num > 7
    figure; plot(check_sg(:,pulse_num))
    legend("channel " + num2str([0:n_ch - 1]'))
    title("Signal from model pulse num " + pulse_num)
elseif tp_num ~= 6
    figure; plot_complex(check_sg(:,:,pulse_num)')
    subplot(2,1,1); title("Signal from model pulse num " + pulse_num)
    legend("channel " + num2str([0:n_ch - 1]'))
    subplot(2,1,2)
    legend("channel " + num2str([0:n_ch - 1]'))
end

%%
if tp_num == 7
    figure; plot(out_sg(:, :,pulse_num)')
    legend("channel " + num2str([0:n_ch - 1]'))
    title("Signal from board pulse num " + pulse_num)
elseif tp_num > 7
    figure; plot(out_sg(:,pulse_num))
    legend("channel " + num2str([0:n_ch - 1]'))
    title("Signal from board pulse num " + pulse_num)
elseif tp_num ~= 6
    figure; plot_complex(out_sg(:,:,pulse_num)')
    subplot(2,1,1); title("Signal from board pulse num " + pulse_num)
    legend("channel " + num2str([0:n_ch - 1]'))
    subplot(2,1,2)
    legend("channel " + num2str([0:n_ch - 1]'))
end


%%
disp("Test point " + tp_num)
% idxs = find(abs(out_sg(ch_num,:,pulse_num))' > noise_level);
if tp_num == 6
    pulse_num = 1;
end
if tp_num == 9
        sqnr_db = check_data_sym(check_sg, out_sg(:,pulse_num)');
        sg_pwr = pow2db(max(abs(out_sg(ch_num,:,pulse_num)).^2));
        disp("SQNR for channel " + num2str(ch_num) + " = " ...
            + num2str(sqnr_db) + " dB, " + ...
            "max signal pwr = " +  sg_pwr + " db")
        subplot(3,1,1); 
        title("Pulse " + num2str(pulse_num) + ": Board vs Model")
elseif tp_num > 7
    for ch_num = 1:n_ch
        sqnr_db = check_data_sym(check_sg(:,pulse_num)', out_sg(:,pulse_num)');
        sg_pwr = pow2db(max(abs(out_sg(ch_num,:,pulse_num)).^2));
        disp("SQNR for channel " + num2str(ch_num) + " = " ...
            + num2str(sqnr_db) + " dB, " + ...
            "max signal pwr = " +  sg_pwr + " db")
        subplot(3,1,1); 
        title("Pulse " + num2str(pulse_num) + ": Board vs Model")
    end
elseif tp_num == 5
     for ch_num = 1:n_ch
        check = check_sg(ch_num,1:end-21,pulse_num)';
        output = out_sg(ch_num,22:end,pulse_num)';
        check_data_sym(check,output);
        sqnr_db = check_data_sym(check(47),output(47), 0);
        sg_pwr = pow2db(max(abs(out_sg(ch_num,:,pulse_num)).^2));
        disp("SQNR for channel " + num2str(ch_num) + " = " ...
            + num2str(sqnr_db) + " dB, " + ...
            "max signal pwr = " +  sg_pwr + " db")
        subplot(3,1,1); 
        title("Pulse " + num2str(pulse_num) + " for channel " + num2str(ch_num) + ": Board vs Model")
    end
else
    for ch_num = 1:n_ch
        [sqnr_db, sqnr_sc_db] = check_data_sym(check_sg(ch_num,:,pulse_num)', out_sg(ch_num,:,pulse_num)');
        sg_pwr = pow2db(max(abs(out_sg(ch_num,:,pulse_num)).^2));
        disp("Channel " + num2str(ch_num) ...
            + " SQNR for descaled rtl = " ...
            + num2str(sqnr_db) + " dB, " ...
            + " SQNR for scaled sg = " ...
            + num2str(sqnr_sc_db) + " dB, " ...
            + "max signal pwr = " +  sg_pwr + " dB")
        subplot(3,1,1); 
        title("Pulse " + num2str(pulse_num) + " for channel " + num2str(ch_num) + ": Board vs Model")
    end
end
%%
if (tp_num > 7)
    n_sf_diff = 20;
    check_data_sym((reshape(check_sg(1:end-n_sf_diff), 1, []))', ...
                   (reshape(out_sg(n_sf_diff+1:end), 1, []))')
else
    check_data_sym((reshape(check_sg(1,:,:), 1, []))', ...
                   (reshape(out_sg(1,:,:), 1, []))')
end

if(isreal(check_sg))
    subplot(2,1,1); 
else
    subplot(3,1,1);
end
title("Whole signal for channel 1: Board vs Model")
