function sqnr_db = check_data_sym( flp_sym, rtl_sym )
    nfft = numel(flp_sym);
    
    % make row-vectors
    if(~isrow(flp_sym))
        flp_sym = flp_sym.';
    end
    if(~isrow(rtl_sym))
        rtl_sym = rtl_sym.';
    end
    
    flp_mean_power = mean(abs(flp_sym).^2);
    rtl_mean_power = mean(abs(rtl_sym).^2);
    rtl_desc_sym = rtl_sym * sqrt(flp_mean_power / rtl_mean_power);
    
    sqnr = flp_mean_power ./ mean(abs(rtl_desc_sym - flp_sym).^2);
       
    sqnr_db = 10*log10(sqnr);

    figure();
    subplot(3,1,1);
        plot( ...
            1 : nfft, real(rtl_sym), 'r', ...
            1 : nfft, imag(rtl_sym), 'b' ...
        );
        legend('Board Re', 'Board Im');
        title("Board vs Model");
    subplot(3,1,2);
        plot( ...
            1 : nfft, real(rtl_desc_sym), 'r', ...
            1 : nfft, real(flp_sym), 'b--' ...
        );
        legend("Board Descaled Re", "Model Re");
    subplot(3,1,3);
        plot( ...
            1 : nfft, imag(rtl_desc_sym), 'r', ...
            1 : nfft, imag(flp_sym), 'b--' ...
        );
        legend("Board Descaled Im", "Model Im");
    
end

