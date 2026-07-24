clear sg
date = "2026-07-22";
date = string(datetime('today', 'Format', 'yyyy-MM-dd'));
folder_basename = "data/";
tp_num = 4; % ADC test point
pulse_num = 2; % pulse num to plot
model_folder = folder_basename + "/2026-07-24/sig";
out_folder = folder_basename + date + "/";
far_field = 41:141;
near_field = 148:187;
hdr_sz = 6;
hdr = 1:hdr_sz;
%%
for ch = 0:7
    launch_ip_comm_test(tp_num, ch, 1, "sig_tp1_test.txt");
end
get_board_data(folder_basename + date + "/", "out");
%%

for ch = 0:7
    try
        sg(ch+1, :, :) = fpga_txt2mat_for_ch(out_folder +"/out_tp" + tp_num +"_ch" + ch + ".hex", ch);
        disp(sg(ch+1, hdr_sz, 1))
    catch
        disp("Found no file for channel " + ch)
    end
end
check_sg = get_mat_data(model_folder, tp_num);
check_sg = check_sg(8:-1:1,:,1:size(sg,3));

input_sg = get_mat_data(model_folder, 1);
input_sg = input_sg(8:-1:1,:,1:size(sg,3));
out_sg = zeros(size(check_sg));
if tp_num == 2 || tp_num == 3
    out_sg(:,far_field, :) = sg(:,hdr_sz + 1:hdr_sz + 101,:);
    out_sg(:, near_field, :) = sg(:,hdr_sz + 1 + 101:end,:);
else
    out_sg = sg(:,hdr_sz+1:end,:);
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
%%
figure; plot_complex(reshape(check_sg, 8, [])')
subplot(2,1,1); title("Whole signal from model")
legend("channel " + num2str([0:7]'))
subplot(2,1,2)
legend("channel " + num2str([0:7]'))
%%
figure; plot_complex(reshape(out_sg, 8, [])')
subplot(2,1,1); title("Whole signal from board")
legend("channel " + num2str([0:7]'))
subplot(2,1,2)
legend("channel " + num2str([0:7]'))
%%
figure; plot_complex(check_sg(:,:,pulse_num)')
subplot(2,1,1); title("Signal from model pulse num " + pulse_num)
legend("channel " + num2str([0:7]'))
subplot(2,1,2)
legend("channel " + num2str([0:7]'))
%%
figure; plot_complex(out_sg(:,:,pulse_num)')
subplot(2,1,1); title("Signal from board pulse num " + pulse_num)
legend("channel " + num2str([0:7]'))
subplot(2,1,2)
legend("channel " + num2str([0:7]'))

%%
for ch_num = 1:7
    sqnr_db = check_data_sym(check_sg(ch_num,:,pulse_num)', out_sg(ch_num,:,pulse_num)');
    disp("SQNR for channel " + num2str(ch_num) + " = " + num2str(sqnr_db) + " dB")
    subplot(3,1,1); 
    title("Pulse " + num2str(pulse_num) + " for channel " + num2str(ch_num) + ": Board vs Model")
end
%%
check_data_sym((reshape(check_sg, 1, []))', (reshape(out_sg, 1, []))')
subplot(3,1,1); title("Whole signal for channel 1: Board vs Model")
