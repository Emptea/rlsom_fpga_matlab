function tp_weight_out = calc_weight(tp_ddr)

    if ndims(tp_ddr) == 3
        n_fft = size(tp_ddr, 2);
        fft_dim = 2;
    else
        n_fft = size(tp_ddr, 3);
        fft_dim = 3;
    end    

    n = 0:n_fft-1;
    d = 0.08 + 0.92*cos(pi/n_fft*(n - n_fft/2)).^2;

    shape = ones(1, ndims(tp_ddr));
    shape(fft_dim) = n_fft;

    tp_weight_out = tp_ddr .* reshape(d, shape);

end