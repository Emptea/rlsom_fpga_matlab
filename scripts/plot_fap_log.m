function plot_fap_log(filename, channels)
arguments
    filename string
    channels (:, 1) double 
end
n_hdr_lines = 6;
n_channels = 8;
n_fap_lines = n_channels * 2 + 1;
n_lines = n_hdr_lines + n_fap_lines;
%% Чтение
lines = readlines(filename);
lines = strip(lines);
lines(lines == "") = [];

%%
N = numel(lines) / n_lines;

data = reshape(lines, n_lines, N);
time = hex2dec(data(n_hdr_lines+1,:));
fap_coeffs_lines = data(end-2*n_channels+1:end,:);
fap_coeffs_lines = uint32(hex2dec(fap_coeffs_lines));
coeffs = double(bitand(fap_coeffs_lines, uint32(16777215)));
coeffs(coeffs >= 2^23) = coeffs(coeffs >= 2^23) - 2^24;
fap_coeffs = complex(coeffs(1:2:end,:) , coeffs(2:2:end,:))/ 2^14;

figure; plot_complex(fap_coeffs(channels,:).')
subplot(2,1,1); legend("re ch" + channels)
subplot(2,1,2); legend("im ch" + channels)

phases = wrapTo180(angle(fap_coeffs) * 180 / pi);
t = (0:size(fap_coeffs,2) - 1) * 20 * 46.4e-6;
figure;plot(t, phases(channels, :).')
title("phases, deg")
legend("ch" + channels)

