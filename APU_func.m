function [P,H,P_i,F] = APU_func(sig, N1, k1, X)

% sig - сигнал на входе
% N1  - размер окна
% k1  - коэффициент усиления порога
% X   - ранг

% P   - значения адаптивного порога
% H   - обнаружения
% P_i - значения адаптивного порога без умножения на k1
% F   - выход алгоритма поиска локальных максимумов

% Параметры
size_window = N1;
mult_koef   = k1;
num_median  = X;          % 0-based индекс ранга
num_kvant   = length(sig);

% 1. Усреднение пар отсчётов
M = ceil(num_kvant/2);
sig_avg = zeros(1, M);
num_pairs = floor(num_kvant/2);
if num_pairs > 0
    sig_avg(1:num_pairs) = (sig(1:2:2*num_pairs-1) + sig(2:2:2*num_pairs))/2;
end
if mod(num_kvant,2) == 1
    sig_avg(M) = sig(num_kvant);
end

% 2. Формирование расширенного массива
%    [нули(1,size_window), sig_avg, зеркальный_хвост(1,size_window)]
n_pad = floor(size_window/2);
mirror_part = zeros(1, n_pad);

if M > 0
    len = min(M, n_pad);
    mirror_part(1:len) = sig_avg(M:-1:M-len+1);
end
ext = [zeros(1, n_pad), sig_avg, mirror_part];

% 3. Вычисление порога в сжатом домене
% shift = size_window - num_median;
data_after_rang = zeros(1, M);
for j = 1:M
    % Окно длины size_window, соответствующее сжатому отсчёту j
    % window = ext(j + shift + 1 : j + shift + size_window);
    window = ext(j: j + size_window - 1);
    sorted_window = sort(window);
    % num_median - 0-based индекс, поэтому +1 для MATLAB
    data_after_rang(j) = sorted_window(num_median + 1);
end
% 4. Разворачивание порога на исходную длину
% P_i = data_after_rang(ceil((1:num_kvant)/2));
% Каждый результат два раза
P_i = repelem(data_after_rang, 2);
P_i = P_i(1:num_kvant);
P = P_i * mult_koef;

% 5. Пороговое обнаружение
% % Устройство выделения локальных максимумов
F = (sig > cat(2,sig(1,2:end), Inf)) & (sig > cat(2,Inf,sig(1,1:end-1)));
Q = sig > P;

H = F & Q;

end
