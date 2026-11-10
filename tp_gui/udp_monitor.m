function udp_monitor()

%% CONFIGURATION
remoteIP   = "193.1.1.1";
remotePort = 5101;
localPort  = 5100;

sendPeriod = 0.5;

cpNames = { ...
    'TP0_WORK', 'TP1_BYPASS', 'TP2_CUT', 'TP3_FAPCH', 'TP4_LOU', ...
    'TP5_SF', 'TP6_DDR', 'TP7_FFT', 'TP8_MAX', 'TP9_FIND', ...
    'TP10_RANK', 'TP11_APU', 'TP12_FAPCH_COEFFS', ...
    'TP13_WEIGHT_OUT', 'TP14_MTI', 'TP99_SDR'};

cpValues = uint32([0:14 99]);
currentCP = uint32(1);

%% STATE
udp = [];
txTimer = [];
sampleIndex = 0;

%% GUI
fig = uifigure("Name", "UDP Monitor", "Position", [100 50 1400 950], "Color", [0.96 0.97 0.98]);
fig.CloseRequestFcn = @onClose;

main = uigridlayout(fig, [3 1]);
main.RowHeight = {105, '1x', 155};
main.Padding = [12 12 12 12];
main.RowSpacing = 10;

% Control panel
panel = uipanel(main, "Title", "Управление", "FontWeight", "bold");
panel.Layout.Row = 1;

pg = uigridlayout(panel, [2 12]);
pg.RowHeight = {25, 35};
pg.ColumnWidth = {105, 65, 100, 65, 105, 65, 105, 65, 80, 80, 95, '1x'};
pg.Padding = [10 8 10 8];
pg.ColumnSpacing = 7;

% Control point
cpLabel = uilabel(pg, "Text", "Контрольная точка:");
cpLabel.Layout.Row = 1;
cpLabel.Layout.Column = [1 2];

cpDropDown = uidropdown(pg, "Items", cpNames, "ItemsData", double(cpValues), "Value", double(currentCP));
cpDropDown.Layout.Row = 2;
cpDropDown.Layout.Column = [1 2];
cpDropDown.ValueChangedFcn = @onChangeCP;

% Range channel (RG)
rgLabel = uilabel(pg, "Text", "Дальностный канал RG:");
rgLabel.Layout.Row = 1;
rgLabel.Layout.Column = [3 4];

rgField = uieditfield(pg, "numeric", "Value", 0, "Limits", [0 255], "RoundFractionalValues", "on");
rgField.Layout.Row = 2;
rgField.Layout.Column = [3 4];

% Channel (NKAN)
channelLabel = uilabel(pg, "Text", "Номер канала:");
channelLabel.Layout.Row = 1;
channelLabel.Layout.Column = [5 6];

channelField = uieditfield(pg, "numeric", "Value", 0, "Limits", [0 65535], "RoundFractionalValues", "on");
channelField.Layout.Row = 2;
channelField.Layout.Column = [5 6];

% Request period
periodLabel = uilabel(pg, "Text", "Период запроса, с:");
periodLabel.Layout.Row = 1;
periodLabel.Layout.Column = [7 8];

periodField = uieditfield(pg, "numeric", "Value", sendPeriod, "Limits", [0.05 60]);
periodField.Layout.Row = 2;
periodField.Layout.Column = [7 8];
periodField.ValueChangedFcn = @onChangePeriod;

% Start
startButton = uibutton(pg, "push", "Text", "Старт", "BackgroundColor", [0.3 0.8 0.4], "FontWeight", "bold");
startButton.Layout.Row = 2;
startButton.Layout.Column = 9;
startButton.ButtonPushedFcn = @onStart;

% Stop
stopButton = uibutton(pg, "push", "Text", "Стоп", "Enable", "off");
stopButton.Layout.Row = 2;
stopButton.Layout.Column = 10;
stopButton.ButtonPushedFcn = @onStop;

% Status
statusLabel = uilabel(pg, "Text", "● UDP остановлен", "FontWeight", "bold", "FontColor", [0.7 0.2 0.2]);
statusLabel.Layout.Row = [1 2];
statusLabel.Layout.Column = [11 12];

%% PLOT

ax = uiaxes(main);
ax.Layout.Row = 2;
ax.Box = "on";
ax.XGrid = "on";
ax.YGrid = "on";
ax.XMinorGrid = "on";
ax.YMinorGrid = "on";

enableDefaultInteractivity(ax);
axtoolbar(ax, {"zoomin", "zoomout", "pan", "restoreview"});

xlabel(ax, "Номер отсчёта");
ylabel(ax, "Значение");
title(ax, "Контрольная точка PHD");

plotRe = plot(ax, nan, nan, "Color", [0.1 0.4 0.9], "LineWidth", 1.0);
hold(ax, "on");
plotIm = plot(ax, nan, nan, "Color", [0.9 0.2 0.2], "LineWidth", 1.0);
hold(ax, "off");

legend(ax, [plotRe plotIm], {'Re', 'Im'}, "Location", "northeast");

%% EVENT LOG

logPanel = uipanel(main, "Title", "Журнал событий", "FontWeight", "bold");
logPanel.Layout.Row = 3;

logArea = uitextarea(logPanel, "Position", [5 5 1065 112], "Editable", "off", "Value", {'Ожидание запуска...'});

logEvent("Программа запущена");
logEvent("Локальный порт: " + localPort + "; удалённый адрес: " + remoteIP + ":" + remotePort);

%% CALLBACKS

    function onStart(~, ~)
        
        if ~isempty(udp)
            return;
        end
        
        try
            udp = udpport("datagram", "IPV4", ...
                "LocalPort", localPort, ...
                "ByteOrder", "little-endian");
            
            configureCallback(udp, ...
                "datagram", 1, @onReceive);
            
            logEvent("UDP открыт, локальный порт " + localPort);
            
            txTimer = timer( ...
                "ExecutionMode", "fixedSpacing", ...
                "Period", sendPeriod, ...
                "BusyMode", "drop", ...
                "TimerFcn", @onSend);
            
            start(txTimer);
            
            statusLabel.Text = "● UDP работает";
            statusLabel.FontColor = [0.1 0.6 0.2];
            
            startButton.Enable = "off";
            stopButton.Enable = "on";
            
            logEvent("Обмен запущен");
            
        catch ME
            
            logEvent("Ошибка запуска: " + string(ME.message));
            
            cleanup();
            
            statusLabel.Text = "● Ошибка UDP";
            statusLabel.FontColor = [0.8 0.1 0.1];
            
            startButton.Enable = "on";
            stopButton.Enable = "off";
            
        end
    end

    function onStop(~, ~)
        
        cleanup();
        
        statusLabel.Text = "● UDP остановлен";
        statusLabel.FontColor = [0.7 0.2 0.2];
        
        startButton.Enable = "on";
        stopButton.Enable = "off";
        
        logEvent("Обмен остановлен");
        
    end

    function onChangeCP(src, ~)
        
        currentCP = uint32(src.Value);
        
        sampleIndex = 0;
        
        idx = find(cpValues == currentCP, 1);
        cpName = cpNames{idx};
        
        title(ax, "Контрольная точка " + cpName);
        
        logEvent("Выбрана КТ " + cpName + ...
            " (formNumber=" + currentCP + ")");
        
    end

    function onChangePeriod(src, ~)
        
        newPeriod = src.Value;
        
        if ~isfinite(newPeriod) || ...
                newPeriod < 0.05 || newPeriod > 60
            
            src.Value = sendPeriod;
            return;
            
        end
        
        sendPeriod = newPeriod;
        
        if ~isempty(txTimer) && isvalid(txTimer)
            
            stop(txTimer);
            txTimer.Period = sendPeriod;
            start(txTimer);
            
        end
        
        logEvent("Новый период отправки: " + ...
            sendPeriod + " с");
        
    end

    function onSend(~, ~)
        
        if isempty(udp)
            return;
        end
        
        try
            
            % Канал берётся непосредственно из поля GUI.
            requestBytes = buildRequest(currentCP, rgField.Value, channelField.Value, 1);
            write(udp, requestBytes, "uint8", remoteIP, remotePort);

            
        catch ME
            
            logEvent("Ошибка передачи: " + ...
                string(ME.message));
            
        end
    end


    function onReceive(src, ~)
        
        while src.NumDatagramsAvailable > 0
            
            try
                % Читаем UDP-датаграмму
                d = read(src, 1, "uint8");
                raw = uint8(d.Data(:));
                
                logEvent("RX: принято " + numel(raw) + " байт");
                
                % Проверяем чётность размера
                if mod(numel(raw), 2) ~= 0
                    logEvent("Ошибка: нечётный размер пакета");
                    continue;
                end
                
                % changeEndian: обмен байтов внутри каждой пары
                tmp = raw(1:2:end);
                raw(1:2:end) = raw(2:2:end);
                raw(2:2:end) = tmp;

                if currentCP == 99

                    % SDR: нет транспортного заголовка POI_TK_Kvit
                    [ok, sdrHeader, blocks] = parseSdrPacket(raw);
                    if ~ok
                        logEvent("Ошибка разбора SDR-пакета");
                        continue;
                    end


                    logEvent("SDR: найдено блоков " + numel(blocks));
                
                    for k = 1:numel(blocks)
                        logEvent("SDR BLOCK " + k + ...
                            ": Counter=" + blocks(k).counter);
                    end
                
                    % Объединяем все SDR-блоки                   
                    allRe = vertcat(blocks.re);
                    allIm = vertcat(blocks.im);
                    
                    % Выводим все блоки последовательно
                    updatePlot(allRe, allIm);
                
                    continue;


                
                else
                
                
                % Разбираем транспортный заголовок
                [ok, transport] = parseTransportPacket(raw);                
                if ~ok
                    logEvent("Ошибка транспортного заголовка");
                    continue;
                end
                logEvent("HEADER WORDS: " + upper(join(string(dec2hex(transport.words(1:12), 4))', " ")));
                
                logEvent("Транспорт: Type=" + transport.msg_type + ...
                    ", Code=" + transport.msg_code + ...
                    ", nw=" + transport.nw);
                
                % Массивы для объединения всех посылок UDP-пакета
                packetRe = [];
                packetIm = [];
                
                words = transport.words(:);
                
                % Delimiter внутреннего заголовка
                delimiter = uint16([ ...
                    hex2dec('4567'); ...
                    hex2dec('0123'); ...
                    hex2dec('BA98'); ...
                    hex2dec('FEDC')]);
                
                if numel(words) < 4
                    logEvent("Недостаточно данных для поиска заголовков");
                    continue;
                end
                
                % Находим начала всех внутренних посылок
                starts = find( ...
                    words(1:end-3) == delimiter(1) & ...
                    words(2:end-2) == delimiter(2) & ...
                    words(3:end-1) == delimiter(3) & ...
                    words(4:end) == delimiter(4));
                
                if isempty(starts)
                    logEvent("Внутренние заголовки не найдены");
                    continue;
                end
                
                blockCount = numel(starts);
                
                logEvent("Найдено внутренних посылок: " + blockCount);
                decodedCount = 0;
                
                % Обрабатываем каждую внутреннюю посылку
                for k = 1:blockCount
                    
                    firstWord = starts(k);
                    
                    if k < blockCount
                        lastWord = starts(k+1) - 1;
                    else
                        lastWord = numel(words);
                    end
                    
                    block = words(firstWord:lastWord);
                    
                    % Разбираем внутренний заголовок
                    [ok, hdr, payload] = parseOutputHeader(block);
                    
                    if ~ok
                        logEvent("Посылка " + k + ": ошибка внутреннего заголовка");
                        continue;
                    end
                    logEvent("HEADER: TP=" + hdr.source + ", Channel=" + hdr.channel + ", RG=" + hdr.range);
                    
                    % Фильтрация по контрольной точке
                    if uint32(hdr.source) ~= currentCP
                        continue;
                    end
                    
                    % Дополнительный заголовок только для КТ №1
                    if hdr.source == 1
                        
                        if numel(payload) < 4
                            logEvent("КТ 1: неполный дополнительный заголовок");
                            continue;
                        end
                        
                        extraHeader = payload(1:4); %#ok<NASGU>
                        payload = payload(5:end);
                        
                    end
                    
                    % Декодируем данные
                    [data, ok, message] = parseSource(hdr.source, payload);
                    
                    if ~ok
                        logEvent("Посылка " + k + ...
                            ": ошибка декодирования: " + message);
                        continue;
                    end
                    
                % Добавляем данные к общему сигналу
                if data.type == "complex"
                
                    packetRe = [packetRe; data.re(:)];
                    packetIm = [packetIm; data.im(:)];
                
                elseif data.type == "coefficients"
                
                    packetRe = [packetRe; data.coef_re(:)];
                    packetIm = [packetIm; data.coef_im(:)];
                
                elseif data.type == "int32"
                
                    packetRe = [packetRe; double(data.values(:))];
                    packetIm = [packetIm; nan(numel(data.values), 1)];
                
                end
                
                decodedCount = decodedCount + 1;
                    
                end
                
                % Обновляем график один раз после обработки всего UDP-пакета
                if ~isempty(packetRe)
                    updatePlot(packetRe, packetIm);
                    
                    logEvent("UDP-пакет обработан: " + ...
                        "посылок=" + decodedCount + ...
                        ", отсчётов=" + numel(packetRe));
                else
                    logEvent("UDP-пакет: нет данных для выбранной КТ");
                end
            end
            catch ME
                
                logEvent("Ошибка приёма: " + string(ME.message));
                
            end
            
        end
    end


    function updatePlot(re, im)
        
        re = double(re(:));
        im = double(im(:));
        
        if isempty(re) || numel(re) ~= numel(im)
            return;
        end
        
        x = 1:numel(re);
        
        % Обновляем линии целиком за один вызов
        set(plotRe, "XData", x, "YData", re);
        set(plotIm, "XData", x, "YData", im);
        
        % Обновляем график без анимации
        drawnow;
        
    end

    function logEvent(message)
        
        if ~isvalid(logArea)
            return;
        end
        
        timestamp = string(datetime("now", ...
            "Format", "HH:mm:ss.SSS"));
        
        entry = char(timestamp + "  " + string(message));
        
        oldLog = logArea.Value;
        
        if ischar(oldLog)
            oldLog = {oldLog};
        end
        
        logArea.Value = [oldLog(:); {entry}];
        
        if numel(logArea.Value) > 200
            logArea.Value = logArea.Value(end-199:end);
        end
        
        drawnow limitrate;
        
    end

    function cleanup()
        
        if ~isempty(txTimer) && isvalid(txTimer)
            
            try
                stop(txTimer);
            catch
            end
            
            delete(txTimer);
            
        end
        
        txTimer = [];
        
        if ~isempty(udp)
            
            try
                configureCallback(udp, "off");
            catch
            end
            
            try
                delete(udp);
            catch
            end
            
            udp = [];
            
        end
    end

    function onClose(~, ~)
        
        cleanup();
        delete(fig);
        
    end

end


%% OUTGOING REQUEST BUILDER: POI_TK_Zapros


function packet = buildRequest(cp, rg, channel, reg_takt)

    % Проверка uint8
    values8 = double([cp, rg]);

    if any(~isfinite(values8)) || any(values8 < 0) || any(values8 > 255) || any(values8 ~= fix(values8))
        error("KT и RG должны быть целыми числами uint8");
    end

    % Проверка uint16
    values16 = double([channel, reg_takt]);

    if any(~isfinite(values16)) || any(values16 < 0) || any(values16 > 65535) || any(values16 ~= fix(values16))
        error("NKAN и REG_TAKT должны быть целыми числами uint16");
    end

    % Формируем структуру в исходном порядке C++
    packet = uint8([0, 3, cp, rg]);

    fields = uint16(values16);

    for k = 1:2
        packet = [packet, uint8(bitand(fields(k), 255)), uint8(bitshift(fields(k), -8))];
    end

    % Аналог changeEndian()
    tmp = packet(1:2:end);
    packet(1:2:end) = packet(2:2:end);
    packet(2:2:end) = tmp;

end



%% TRANSPORT PACKET PARSER: POI_TK_Kvit

function [valid, packet] = parseTransportPacket(raw)

valid = false;

packet = struct( ...
    "msg_code", uint8(0), ...
    "msg_type", uint8(0), ...
    "nw", 0, ...
    "words", uint16([]));

raw = uint8(raw(:));

if numel(raw) < 4
    return;
end

packet.msg_code = raw(1);
packet.msg_type = raw(2);

% POI_TK_Kvit: Header(Type=3, Code=0).
if packet.msg_type ~= 3 || packet.msg_code ~= 0
    return;
end

packet.nw = double(uint16(raw(3)) + ...
    bitshift(uint16(raw(4)), 8));

expectedBytes = 4 + 2 * packet.nw;

if numel(raw) ~= expectedBytes
    return;
end

if packet.nw > 0
    
    b = reshape(raw(5:end), 2, []);
    
    packet.words = uint16(b(1,:)).' + ...
        bitshift(uint16(b(2,:)).', 8);
    
end

valid = true;

end


%% INTERNAL OUTPUT HEADER PARSER

function [valid, hdr, payload] = parseOutputHeader(words)

    valid = false;
    hdr = struct();
    payload = uint16([]);

    words = uint16(words(:));

    if numel(words) < 12
        return;
    end

    % Delimiter
    delHigh = bitor(bitshift(uint32(words(2)), 16), uint32(words(1)));
    delLow = bitor(bitshift(uint32(words(4)), 16), uint32(words(3)));

    if delHigh ~= uint32(hex2dec('01234567')) || delLow ~= uint32(hex2dec('FEDCBA98'))
        return;
    end

    % Packet number
    hdr.formNumber = bitor(bitshift(uint32(words(6)), 16), uint32(words(5)));

    % Timestamp
    hdr.timestamp = bitor(bitshift(uint64(words(10)), 48), ...
                   bitor(bitshift(uint64(words(9)), 32), ...
                   bitor(bitshift(uint64(words(8)), 16), uint64(words(7)))));

    % Bit fields: channel (3), range (13), tp (16)
    headerWord = bitor(bitshift(uint32(words(12)), 16), uint32(words(11)));

    hdr.channel = bitand(headerWord, uint32(7));
    hdr.range = bitand(bitshift(headerWord, -3), uint32(8191));
    hdr.source = bitshift(headerWord, -16);

    payload = words(13:end);

    valid = true;

end


%% SOURCE DECODER

function [data, valid, message] = parseSource(source, words)

valid = false;
message = "";
data = struct();

source = double(source);
words = uint16(words(:));

switch source
    
    case 1
        expectedValues = 232;
        kind = "complex";
        
    case {2, 3, 4}
        expectedValues = 164;
        kind = "complex";
        
    case 5
        expectedValues = 141;
        kind = "complex";
        
    case {6, 7, 13}
        expectedValues = 512;
        kind = "complex";
        
    case {8, 10, 11}
        expectedValues = 141;
        kind = "int32";
        
    case 9
        expectedValues = 141 * 5;
        kind = "int32";
        
    case 12
        expectedValues = 16;
        kind = "int32";
        
    case 14
        expectedValues = 141;
        kind = "complex";
        
    otherwise
        
        message = "Неизвестный source";
        return;
        
end

% Complex sample uses two uint16 words (Re and Im).
% Each int32 value also uses two uint16 words.

expectedWords = expectedValues * 2;

if numel(words) ~= expectedWords
    
    message = sprintf( ...
        "Неверный размер payload: ожидалось %d слов, получено %d", ...
        expectedWords, numel(words));
    
    return;
    
end

data.source = source;
data.type = kind;

if kind == "complex"
    
    signedValues = typecast(words, "int16");
    
    data.re = double(signedValues(1:2:end));
    data.im = double(signedValues(2:2:end));
    
    % Sources 2, 3, 4:
    % 101 far samples, 20 zeros,
    % 40 near samples, 3 zeros.
    
    if ismember(source, [2 3 4])
        
        data.farZoneRe = data.re(1:101);
        data.farZoneIm = data.im(1:101);
        
        data.nearZoneRe = data.re(122:161);
        data.nearZoneIm = data.im(122:161);
        
    end
    
else
    
    int32Values = decodeInt32(words);
    
    if source == 12
        
        % First 8 coef_re, then 8 coef_im.
        data.type = "coefficients";
        
        data.coef_re = double(int32Values(1:8)) / 2^14;
        data.coef_im = double(int32Values(9:16)) / 2^14;
        
    else
        
        data.values = int32Values;
        
    end
    
end

valid = true;
message = "OK";

end


function [valid, sdrHeader, blocks] = parseSdrPacket(raw)

    valid = false;
    sdrHeader = struct();
    blocks = struct([]);

    raw = uint8(raw(:));

    HEADER_SIZE = 12;
    BLOCK_SIZE = 936;
    BLOCK_WORDS = BLOCK_SIZE / 2;
    SAMPLES_COUNT = 232;

    if numel(raw) < HEADER_SIZE + BLOCK_SIZE
        return;
    end

    if mod(numel(raw), 2) ~= 0
        return;
    end

    % changeEndian уже выполнен в onReceive
    bytes = reshape(raw, 2, []);

    words = uint16(bytes(1,:)).' + ...
        bitshift(uint16(bytes(2,:)).', 8);

    % Общий заголовок SDR
    sdrHeader.words = words(1:6);
    sdrHeader.bytes = raw(1:HEADER_SIZE);

    % Маркер начала блока
    delimiter = uint16([hex2dec('0123'); hex2dec('4567')]);

    % Ищем все маркеры после общего заголовка
    starts = find( ...
        words(7:end-1) == delimiter(1) & ...
        words(8:end) == delimiter(2)) + 6;

    if isempty(starts)
        return;
    end

    % Проверяем структуру блоков
    if any(diff(starts) ~= BLOCK_WORDS)
        return;
    end

    % Проверяем, что последний блок помещается целиком
    if starts(end) + BLOCK_WORDS - 1 > numel(words)
        return;
    end

    blockCount = numel(starts);

    blocks = repmat(struct( ...
        "counter", uint32(0), ...
        "re", zeros(SAMPLES_COUNT, 1), ...
        "im", zeros(SAMPLES_COUNT, 1)), blockCount, 1);

    for k = 1:blockCount

        startWord = starts(k);

        % Счётчик блока
        blocks(k).counter = bitor( ...
            bitshift(uint32(words(startWord+2)), 16), ...
            uint32(words(startWord+3)));

        % Данные Re / Im
        sampleWords = words( ...
            startWord+4 : startWord+BLOCK_WORDS-1);

        if numel(sampleWords) ~= SAMPLES_COUNT * 2
            blocks = struct([]);
            return;
        end

        samples = typecast(sampleWords, "int16");

        blocks(k).re = double(samples(1:2:end));
        blocks(k).im = double(samples(2:2:end));

    end

    valid = true;

end

%% UINT16 WORDS -> INT32 VALUES

function values = decodeInt32(words)

words = uint16(words(:));

if mod(numel(words), 2) ~= 0
    error("Количество uint16 слов для int32 должно быть чётным");
end

low = uint32(words(1:2:end));
high = uint32(words(2:2:end));

raw = bitor(low, bitshift(high, 16));

values = typecast(raw(:), "int32");

end


%% FOUR UINT16 WORDS -> UINT64

function value = combine64(words)

words = uint16(words(:));

if numel(words) ~= 4
    error("Для uint64 требуется ровно четыре uint16 слова");
end

value = uint64(0);

for k = 1:4
    
    value = bitor(value, ...
        bitshift(uint64(words(k)), 16 * (k-1)));
    
end

end