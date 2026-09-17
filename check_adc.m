close all
date = "2026-09-14";
date = string(datetime('today', 'Format', 'yyyy-MM-dd'));
folder_basename = "data/";
tp_num = tp.TP_SF; % ADC test point
range_gate = 46;
pulse_num = 27; % pulse num to plot
model_folder = folder_basename + "/2026-09-17/sig";
out_folder = folder_basename + date + "/";
far_field = 41:141;
near_field = 148:187;
hdr_sz = 6;
hdr = 1:hdr_sz;
noise_level = 40;
n_ch = 8;
n_transfers = 20; % = n_packets / 4, max 250

if tp_num > tp.TP_FFT
    ch = 0;
    if (tp_num ~= tp.TP_FAPCH_COEFFS)
        n_ch = 1;
    end
end
%%
if tp_num > tp.TP_FFT
    launch_ip_comm_test(tp_num, ch, range_gate, 250, "adc_2_targets_1000_packets_1709.txt");
else
    for ch = 0:7
        launch_ip_comm_test(tp_num, ch, range_gate, n_transfers, "adc_2_targets_1000_packets_1709.txt");
    end
end
get_board_data(folder_basename + date + "/", "out");
%%
clear sg
sg = read_board_data(out_folder, tp_num, range_gate, hdr_sz);
third_dim = 1:(size(sg,3));

switch tp_num
    case {tp.TP_BYPASS, tp.TP_SF}
        model_sg = get_mat_data( ...
            model_folder, tp_num, range_gate);
        check_sg = model_sg(:,:,1:size(sg,3));
        out_sg = sg(:,hdr_sz+1:end,:);
    case {tp.TP_CUT, tp.TP_FAPCH}
        model_sg = get_mat_data( ...
            model_folder, tp_num, range_gate);

        check_sg = [ ...
            model_sg(:,far_field,1:size(sg,3)), ...
            zeros(8,20,size(sg,3)), ...
            model_sg(:,near_field,1:size(sg,3)), ...
            zeros(8,3,size(sg,3))];
        out_sg = sg(:,[hdr_sz+1:end],:);
    case {tp.TP_LOU}
        model_sg = get_mat_data( ...
            model_folder, tp_num, range_gate);

        check_sg = [ ...
            model_sg(:,1:101,1:size(sg,3)), ...
            zeros(8,20,size(sg,3)), ...
            model_sg(:,102:end,1:size(sg,3)), ...
            zeros(8,3,size(sg,3))];
        out_sg = sg(:,[hdr_sz+1:end],:);
    case tp.TP_DDR
        clear tp5_sg
        for ch = 0:7
            try
                hexname = out_folder + "/out_tp5_ch" + ch ...
                    + "_rg" + range_gate + ".hex";
                tp5_sg(ch+1,:,:) = fpga_txt2mat_for_ch(hexname);
                disp(sg(ch+1, hdr_sz, 1))
            catch
                disp("Found no file for channel " + ch)
            end
        end
        check_sg = tp5_sg(:,hdr_sz + range_gate + 1,:);
        check_sg = permute(check_sg, [1 3 2]);
        out_sg = sg(:,hdr_sz+1:end,end);
        check_sg = check_sg(:,end-511:end);

    case tp.TP_FFT
        model_sg = get_mat_data( ...
            model_folder, tp_num, range_gate);

        check_sg = [model_sg(:,1:101,third_dim), ...
            model_sg(:,102:end,third_dim)];
        out_sg = abs(sg(:,hdr_sz+1:end,:));
        check_sg = abs(check_sg);

    case tp.TP_FIND
        ch = 0;
        try
            hexname = out_folder + "/out_tp8_ch0_rg" ...
                + range_gate + ".hex";
            tp8_sg = fpga_txt2mat_for_ch( ...
                hexname, ch, range_gate);
            disp(sg(hdr_sz, 1))
        catch
            disp("Found no file for channel " + ch)
        end
        i = size(tp8_sg, 2);
        M = 26;
        check_sg = tp8_sg( ...
            hdr_sz+1:end, ...
            [i-M-1, i-M, i-1, i, i-M/2]).';
        check_sg = check_sg(:);
        out_sg = sg(hdr_sz+1:end, :);


    case {tp.TP_MAX, tp.TP_RANK, tp.TP_APU, tp.TP_FAPCH_COEFFS}
        model_sg = get_mat_data( ...
            model_folder, tp_num, range_gate);
        check_sg = model_sg(:,1:size(sg,2));
        out_sg = sg(hdr_sz+1:end, :);

    otherwise
        model_sg = get_mat_data( ...
            model_folder, tp_num, range_gate);

        check_sg = [ ...
            model_sg(:,1:101,third_dim), ...
            zeros(8,20,size(sg,3)), ...
            model_sg(:,102:end,third_dim), ...
            zeros(8,3,size(sg,3))];
        out_sg = sg(:,[hdr_sz+1:end],:);
end
save_for_model(out_sg, tp_num);
%%
switch tp_num
    case tp.TP_FFT
        figure; plot(check_sg(:, :,pulse_num).')
        legend("channel " + num2str([0:n_ch - 1].'))
        title("Signal from model pulse num " + pulse_num)
    case tp.TP_FIND
        figure; plot(check_sg)
        legend("channel " + num2str([0:n_ch - 1].'))
        title("Signal from model pulse num " + pulse_num)
    case {tp.TP_MAX, tp.TP_RANK, tp.TP_APU}
        figure; plot(check_sg(:,pulse_num))
        legend("channel " + num2str([0:n_ch - 1].'))
        title("Signal from model pulse num " + pulse_num)
    case tp.TP_DDR
        disp("TODO: plot")
    case tp.TP_FAPCH_COEFFS
        figure; plot_complex(check_sg.')
        subplot(2,1,1); title("Signal from model pulse num " + pulse_num)
        legend("channel " + num2str([0:n_ch - 1].'))
        subplot(2,1,2);
        legend("channel " + num2str([0:n_ch - 1].'))
    otherwise
        figure; plot_complex(check_sg(:,:,pulse_num).')
        subplot(2,1,1); title("Signal from model pulse num " + pulse_num)
        legend("channel " + num2str([0:n_ch - 1].'))
        subplot(2,1,2)
        legend("channel " + num2str([0:n_ch - 1].'))
end
%%
switch tp_num
    case tp.TP_FFT
        figure; plot(out_sg(:, :,pulse_num).')
        legend("channel " + num2str([0:n_ch - 1].'))
        title("Signal from board pulse num " + pulse_num)
    case {tp.TP_MAX, tp.TP_RANK, tp.TP_APU}
        figure; plot(out_sg(:,pulse_num))
        legend("channel " + num2str([0:n_ch - 1].'))
        title("Signal from board pulse num " + pulse_num)
    case tp.TP_DDR
        disp("TODO: plot")
    case tp.TP_FAPCH_COEFFS
        figure; plot_complex(out_sg.')
        subplot(2,1,1); title("Signal from board pulse num " + pulse_num)
        legend("channel " + num2str([0:n_ch - 1].'))
        subplot(2,1,2);
        legend("channel " + num2str([0:n_ch - 1].'))
    otherwise
        figure; plot_complex(out_sg(:,:,pulse_num).')
        subplot(2,1,1); title("Signal from board pulse num " + pulse_num)
        legend("channel " + num2str([0:n_ch - 1].'))
        subplot(2,1,2)
        legend("channel " + num2str([0:n_ch - 1].'))
end


%%
disp("Test point " + tp_num)
% idxs = find(abs(out_sg(ch_num,:,pulse_num)).' > noise_level);
if tp_num == 6
    pulse_num = 1;
end
switch tp_num
    case tp.TP_SF
        for ch_num = 1:n_ch
            check  = check_sg(ch_num,:,pulse_num).';
            output = out_sg(ch_num,:,pulse_num).';

            [max_err_db, sqnr_sc_db] = check_data_sym(check, output, 1, 1);
            % % check_data_sym(check(range_gate), output(range_gate), 0,1);

            sg_pwr = pow2db(max(abs(out_sg(ch_num,:,pulse_num)).^2));

            disp("Channel " + num2str(ch_num) ...
                + " Max Error dB = " ...
                + num2str(max_err_db) + " dB, " ...
                + " SQNR for scaled sg = " ...
                + num2str(sqnr_sc_db) + " dB, " ...
                + "max signal pwr = " + sg_pwr + " dB")

            subplot(3,1,1);
            title("Pulse " + num2str(pulse_num) ...
                + " for channel " + num2str(ch_num) ...
                + ": Board vs Model")
        end
    case tp.TP_FIND
        [max_err_db, sqnr_sc_db] = check_data_sym(check_sg, out_sg(:,pulse_num).');
        sg_pwr = pow2db(max(abs(out_sg(ch_num,:,pulse_num)).^2));

        disp("Channel " + num2str(ch_num) ...
            + " Max Error dB = " ...
            + num2str(max_err_db) + " dB, " ...
            + " SQNR for scaled sg = " ...
            + num2str(sqnr_sc_db) + " dB, " ...
            + "max signal pwr = " + sg_pwr + " dB")

        subplot(3,1,1);
        title("Pulse " + num2str(pulse_num) + ": Board vs Model")

    case {tp.TP_MAX, tp.TP_RANK, tp.TP_APU}
        [max_err_db, sqnr_sc_db] = check_data_sym( ...
            check_sg(:,pulse_num).', ...
            out_sg(:,pulse_num).');

        sg_pwr = pow2db(max(abs(out_sg(:,pulse_num)).^2));


        disp("Channel " + num2str(ch_num) ...
            + " Max Error dB = " ...
            + num2str(max_err_db) + " dB, " ...
            + " SQNR for scaled sg = " ...
            + num2str(sqnr_sc_db) + " dB, " ...
            + "max signal pwr = " + sg_pwr + " dB")
        subplot(3,1,1);
        title("Pulse " + num2str(pulse_num) + ": Board vs Model")
    case tp.TP_FAPCH_COEFFS
        for ch_num = 1:n_ch
            [max_err_db, sqnr_sc_db] = check_data_sym( ...
                2^14 * check_sg(ch_num,:).', ...
                out_sg(ch_num,:).', 0);

            sg_pwr = pow2db(max(abs(out_sg(ch_num,:)).^2));

            check_scaled = round(check_sg(ch_num, 1) * 2^14);
            disp("Channel " + ch_num + ": board = " ...
                + real(out_sg(ch_num, 1)) + " + "  + imag(out_sg(ch_num, 1)) ...
                + "i, model = " ...
                + real(check_scaled) + " + "  + imag(check_scaled) + "i");
        end

    otherwise  % tp_num = 0:4, 6, or 7
        for ch_num = 1:n_ch
            [max_err_db, sqnr_sc_db] = check_data_sym( ...
                check_sg(ch_num,:,pulse_num).', ...
                out_sg(ch_num,:,pulse_num).', 1, 1);

            sg_pwr = pow2db(max(abs(out_sg(ch_num,:,pulse_num)).^2));

            disp("Channel " + num2str(ch_num) ...
                + " Max Error dB = " ...
                + num2str(max_err_db) + " dB, " ...
                + " SQNR for scaled sg = " ...
                + num2str(sqnr_sc_db) + " dB, " ...
                + "max signal pwr = " + sg_pwr + " dB")

            subplot(3,1,1);
            title("Pulse " + num2str(pulse_num) ...
                + " for channel " + num2str(ch_num) ...
                + ": Board vs Model")
        end
end
%%

if tp_num == tp.TP_FAPCH_COEFFS
    check_data_sym(check_sg(1,:).', ...
        out_sg(1,:).')
    sgtitle("Whole signal for channel 1: Board vs Model")
elseif (tp_num > 7)
    n_sf_diff = 20;
    check_data_sym((reshape(check_sg(1:end-n_sf_diff), 1, [])).', ...
        (reshape(out_sg(n_sf_diff+1:end), 1, [])).')
    sgtitle("Whole signal for channel 1: Board vs Model")
else
    for ch_num = 1:8
        check_data_sym((reshape(check_sg(ch_num,:,:), 1, [])).', ...
            (reshape(out_sg(ch_num,:,:), 1, [])).',1,1)
        sgtitle(sprintf("Whole signal for channel %d: Board vs Model", ch_num));
    end
end

if(isreal(check_sg) || tp_num == tp.TP_FAPCH_COEFFS)
    subplot(2,1,1);
else
    subplot(3,1,1);
end

%%
figure;
tiledlayout(4, 2, "TileSpacing", "compact");
for ch_num = 1:8
    nexttile;
    plot(reshape(real(out_sg(ch_num,:,:)),[],1) - reshape(real(check_sg(ch_num,:,:)), [], 1))
    title(sprintf('Channel %d', ch_num));
    grid on;
end
sgtitle(sprintf("Signal Difference — Re"));
%%
if(~isreal(check_sg))
    figure;
    tiledlayout(4, 2, "TileSpacing", "compact");
    for ch_num = 1:8
        nexttile;
        plot(reshape(imag(out_sg(ch_num,:,:)), [], 1) - reshape(imag(check_sg(ch_num,:,:)), [], 1))
        title(sprintf('Channel %d', ch_num));
        grid on;
    end
    sgtitle(sprintf("Signal Difference — Pulse %d Im", pulse_num));
end