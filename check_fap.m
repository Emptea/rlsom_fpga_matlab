clear sg
folder_basename = "data/2026-07-20";
tp_num = 3; % FAPCH test point
pulse_num = 4; % pulse num to plot

model_folder = folder_basename + "/sig";
out_folder = folder_basename + "/out";
far_field = 41:141;
near_field = 148:187;

for ch = 0:7
    try
        sg(ch+1, :, :) = fpga_txt2mat_for_ch(out_folder +"/out_tp" + tp_num +"_ch" + ch + ".hex", ch);
    catch
        disp("Found no file for channel " + ch)
    end
end
load(model_folder + "/sig_tp2_fap.mat")
check_sg = tp2_fap(:,:,1:size(sg,3));
out_sg = zeros(size(check_sg));
if tp_num == 3
    out_sg(:,far_field, :) = sg(:,1:101,:);
    out_sg(:, near_field, :) = sg(:,102:end,:);
end
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
    check_data_sym(check_sg(ch_num,1:187,pulse_num)', out_sg(ch_num,1:187,pulse_num)')
    subplot(3,1,1); 
    title("Pulse " + num2str(pulse_num) + " for channel " + num2str(ch_num) + ": Board vs Model")
end
%%
check_data_sym((reshape(check_sg, 8, [])', reshape(out_sg, 8, [])')
subplot(3,1,1); title("Whole signal: Board vs Model")