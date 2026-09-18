function tp6 = weight_fft(tp5)

    [~, ~, n_fft, ~] = size(tp5);
    
    n = 0:n_fft-1;
    d = 0.08 + 0.92*cos(pi/n_fft*(n - n_fft/2)).^2;
    
    tp5_d = tp5 .* reshape(d, 1, 1, [], 1);
    
    tp6 = fft(tp5_d, 512, 3) ./ 512;

end