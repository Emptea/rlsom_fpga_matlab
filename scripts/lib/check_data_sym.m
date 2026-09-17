function [max_err_db, sqnr_sc_db] = check_data_sym( flp_sym, rtl_sym , plot_on, is_scaled)
arguments
    flp_sym double
    rtl_sym double
    plot_on double = 1
    is_scaled double = 0
end
nfft = numel(flp_sym);

% make row-vectors
if(~isrow(flp_sym))
    flp_sym = flp_sym.';
end
if(~isrow(rtl_sym))
    rtl_sym = rtl_sym.';
end

flp_mean_power = mean(abs(flp_sym).^2);
% rtl_mean_power = mean(abs(rtl_sym).^2);
% rtl_desc_sym = rtl_sym * sqrt(flp_mean_power / rtl_mean_power);
% rtl_desc_sym = fpga_fxp2double(rtl_sym);
rtl_desc_sym = rtl_sym;



if (~is_scaled)
    flp_sc_sym = fpga_double2fxp(flp_sym);
else
    flp_sc_sym = flp_sym;
end
flp_mean_power_sc = mean(abs(flp_sc_sym).^2);
sqnr_sc = flp_mean_power_sc ./ mean(abs(rtl_sym - flp_sc_sym).^2);
sqnr_sc_db = 10*log10(sqnr_sc);

sqnr = mean(abs(rtl_sym - flp_sc_sym).^2);
sqnr = max(abs(rtl_sym - flp_sc_sym).^2);
max_err_db = pow2db(sqnr);


if(plot_on)
    figure();
    if(isreal(flp_sym))
        ax1 = subplot(2,1,1);
        plot(1 : nfft, real(rtl_sym), 'r');
        legend('Board');
        title("Board vs Model");
        ax2 = subplot(2,1,2);
        plot( ...
            1 : nfft, real(rtl_sym), 'r', ...
            1 : nfft, real(flp_sc_sym), 'b--' ...
            );
        legend("Board", "Model Scaled");
        linkaxes([ax1, ax2], 'x');
    else
        ax1 = subplot(3,1,1);
        plot( ...
            1 : nfft, real(rtl_sym), 'r', ...
            1 : nfft, imag(rtl_sym), 'b' ...
            );
        legend('Board Re', 'Board Im');
        title("Board vs Model");
        ax2 = subplot(3,1,2);
        plot( ...
            1 : nfft, real(rtl_sym), 'r', ...
            1 : nfft, real(flp_sc_sym), 'b--' ...
            );
        legend("Board Re", "Model Scaled Re");
        ax3 = subplot(3,1,3);
        plot( ...
            1 : nfft, imag(rtl_sym), 'r', ...
            1 : nfft, imag(flp_sc_sym), 'b--' ...
            );
        legend("Board Im", "Model Scaled Im");
        linkaxes([ax1, ax2, ax3], 'x');
    end   
end

