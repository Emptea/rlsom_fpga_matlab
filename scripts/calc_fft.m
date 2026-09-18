function tp_fft = calc_fft(tp_weight_out)

    if ndims(tp_weight_out) == 3
        fft_dim = 2;
    else
        fft_dim = 3;
    end
    n_fft = size(tp_weight_out, fft_dim);
    tp_fft = fft(tp_weight_out, n_fft, fft_dim) ./ n_fft;

end