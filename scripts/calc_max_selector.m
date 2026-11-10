function [max_val, idx_fft, idx_ch] = calc_max_selector(sg)

[max_fft, idx_fft_all] = max(sg, [], 3);
[max_val, idx_ch] = max(max_fft, [], 1);

max_val     = squeeze(max_val);
idx_ch      = squeeze(idx_ch);
idx_fft_all = squeeze(idx_fft_all);

[n_rg, n_packets] = size(idx_ch);

[rg, packet] = ndgrid(1:n_rg, 1:n_packets);

idx = sub2ind(size(idx_fft_all), idx_ch, rg, packet);
idx_fft = idx_fft_all(idx);

idx_ch = idx_ch - 1;

end