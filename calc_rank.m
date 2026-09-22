function tp_rank = calc_rank(tp_max)

window = 15;
n_rank = 10;

tp_rank = zeros(size(tp_max));

for packet = 1:size(tp_max, 2)

    far = calc_rank_part(tp_max(1:101, packet), window, n_rank);
    close = calc_rank_part(tp_max(102:141, packet), window, n_rank);

    tp_rank(:, packet) = [far(1:101); close(1:40)];
end
delay = 13;
tp_rank = [zeros(size(tp_rank, 1), delay), ...
           tp_rank(:, 1:end-delay)];

end


function y = calc_rank_part(x, window, n_rank)

% Усреднение соседних пар
n = length(x);

idx1 = 1:2:n;
idx2 = min(idx1 + 1, n);

avs = (x(idx1) + x(idx2)) / 2;

% Симметричное дополнение нулями: 7 слева + 7 справа
n_pad = floor(window / 2);

extended_avs = [zeros(n_pad, 1); ...
                avs; ...
                zeros(n_pad, 1)];

% Ранговый фильтр
rank_out = zeros(size(avs));

for i = 1:length(avs)
    sorted_window = sort(extended_avs(i:i+window-1));
    rank_out(i) = sorted_window(n_rank + 1);
end

% Каждый результат два раза
y = repelem(rank_out, 2);

end