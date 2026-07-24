function RLSmini_mask(freq, sampleFreq, omega)
% Функция инициализации параметров для миниатюрной РЛС с адаптивной фильтрацией RLS
% Входные параметры:
%   freq       - несущая частота РЛС (Гц)
%   sampleFreq - частота дискретизации АЦП (Гц)
%   omega      - угловая скорость вращения антенны (рад/с)

% ========== ОСНОВНЫЕ ПАРАМЕТРЫ РЛС ==========
paramRLSmini.freq = freq;                % несущая частота РЛС 9.23 ГГц (0.0325 м)
paramRLSmini.lambda = freq2wavelen(freq); % длина волны на частоте freq (пример: 0.0325 м)
paramRLSmini.sampleFreq = sampleFreq;    % частота дискретизации (например, 5e6 Гц)
paramRLSmini.sampleTime = 1/sampleFreq;  % период дискретизации (длительность одного отсчёта, 0.2e-6 с)
paramRLSmini.pulsePeriod = 232*paramRLSmini.sampleTime; % период повторения импульсов (232 отсчёта)
paramRLSmini.omega = omega;              % угловая скорость вращения антенны (2 рад/с)

% ========== РАЗМЕРЫ ВРЕМЕННЫХ ИНТЕРВАЛОВ (В ОТСЧЁТАХ) ==========
paramRLSmini.nSfarTX = 40;   % Количество отсчётов зондирующего сигнала в дальней зоне (передача)
paramRLSmini.nSfarRX = 101;  % Количество отсчётов принимаемого сигнала в дальней зоне
paramRLSmini.nSnearTX = 6;   % Количество отсчётов зондирующего сигнала в ближней зоне (передача)
paramRLSmini.nSnearRX = 40;  % Количество отсчётов принимаемого сигнала в ближней зоне
paramRLSmini.nSPAT = 40;     % Количество отсчётов строб-импульса для системы фазовой автоподстройки (ФАП)
paramRLSmini.nSw = 5;        % Количество отсчётов для переключения рабочих точек

% ========== РАЗМЕРЫ ВРЕМЕННЫХ ИНТЕРВАЛОВ (В ДАЛЬНОСТЯХ) ==========
paramRLSmini.distF = ((1:paramRLSmini.nSfarRX)...
    + paramRLSmini.nSfarTX/2).*paramRLSmini.sampleTime.*physconst('l')./2;  % Количество отсчётов принимаемого сигнала в дальней зоне
paramRLSmini.distN = ((1:paramRLSmini.nSnearRX)...
    + paramRLSmini.nSnearTX/2).*paramRLSmini.sampleTime.*physconst('l')./2;   % Количество отсчётов зондирующего сигнала в ближней зоне (передача)

% ========== ИНДЕКСЫ ВРЕМЕННЫХ ИНТЕРВАЛОВ В БУФЕРЕ ==========
paramRLSmini.iMfarTX = 1:40;       % Индексы отсчётов зондирующего сигнала ДЗ (дальняя зона)
paramRLSmini.iMfarRX = 41:141;     % Индексы отсчётов принимаемого сигнала ДЗ
paramRLSmini.iMnearTX = 142:147;   % Индексы отсчётов зондирующего сигнала БЗ (ближняя зона)
paramRLSmini.iMnearRX = 148:187;   % Индексы отсчётов принимаемого сигнала БЗ
paramRLSmini.iMPAT = 188:227;      % Индексы отсчётов строба ФАП (фазовая автоподстройка)
paramRLSmini.iMsw = 228:232;       % Индексы отсчётов для переключения рабочих точек

% ========== ПАРАМЕТРЫ БУФЕРИЗАЦИИ И АЦП ==========
paramRLSmini.buffSize = 232;               % Общий размер буфера (сумма всех интервалов)
paramRLSmini.sigBuffer = zeros(paramRLSmini.buffSize,1); % Буфер для хранения отсчётов принятого сигнала
paramRLSmini.numChADC = 8;                 % Количество каналов АЦП (многоканальный приём)

% ========== ПАРАМЕТРЫ КОНТРОЛЬНОГО СИГНАЛА И АМПЛИТУДНО-ФАЗОВЫХ ИСКАЖЕНИЙ ==========
paramRLSmini.ctrlSigA = 1e-3;              % Амплитуда контрольного (калибровочного) сигнала

% Амплитудно-фазовые рассогласования по 8 каналам приёма
% Каждый элемент: амплитуда * exp(1i * фаза в радианах)
paramRLSmini.PhMisM = [1*exp(1i*deg2rad(0));      
                        1.2*exp(1i*deg2rad(-3));  
                        1.13*exp(1i*deg2rad(0.5)); 
                        0.75*exp(1i*deg2rad(0.15));
                        1.2*exp(1i*deg2rad(0));    
                        1.23*exp(1i*deg2rad(-1.7));
                        0.5*exp(1i*deg2rad(-4));   
                        0.93*exp(1i*deg2rad(0.3))];

% ========== ПАРАМЕТРЫ ДЛЯ ФОРМИРОВАНИЯ ДИАГРАММЫ НАПРАВЛЕННОСТИ ==========
% Углы (в градусах) для формирования лучей (beamforming)
paramRLSmini.beamFormAng = [5.3125 15.9375 26.5625 37.1875 47.8125 58.4375 69.0625 79.6875];

N = 512;
PRF = 1 / paramRLSmini.pulsePeriod;

% k = 1:N;
% f_d = (k - 1) .* (PRF / N);
% f_d(k > N/2+1) = (k(k > N/2+1) - 1 - N) .* (PRF / N);
% paramRLSmini.vRarray = (paramRLSmini.lambda / 2) * f_d;

f = (-N/2 : N/2-1) * (PRF/N);
paramRLSmini.vRarray = -f*paramRLSmini.lambda/2;
paramRLSmini.vRarray = fftshift(paramRLSmini.vRarray);



% 
Bolz = physconst('b');
T = 273+60;
B = 1e6;
Nf = db2pow(4);
Noise = Nf*T*B*Bolz;
paramRLSmini.NPowdBm = 10*log10(Noise/1e-3);




% ========== СОХРАНЕНИЕ СТРУКТУРЫ В РАБОЧЕЕ ПРОСТРАНСТВО ==========
assignin('base', 'paramRLSmini', paramRLSmini); % Экспорт структуры в базовое рабочее пространство
end