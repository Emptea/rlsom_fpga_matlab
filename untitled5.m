for i = 1:8
    err = squeeze(abs(check_tp7_fft_rg46(i,:, :) - rtl_tp7_fft_rg46.data(i,:, :)));
    figure;
    imagesc([0 50], [1 512], err);
    axis xy;
    colorbar;
    title("bit error, ch" + (i - 1));
end