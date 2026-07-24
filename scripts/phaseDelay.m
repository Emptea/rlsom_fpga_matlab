classdef phaseDelay < matlab.System
% phaseDelay Системный объект для расчета фазовых задержек в антенной решетке
% Вычисляет фазовые сдвиги для имитатора сигналов или для обработки 
% сигналов  в зависимости от режима работы

    properties (Nontunable)
        % N - Количество элементов в антенной решетке
        % Целое положительное число, определяющее число антенных элементов
        N (1,1) {mustBeInteger} = 8; % Кол-во элементов
        
        % freq - Рабочая частота [Гц]
        % Частота сигнала, используемая для расчета длины волны
        freq (1,1) {mustBeNumeric} = 9.39e9; % Рабочая частота, [ГГц]
        
        % stp - Шаг между элементами решетки [м]
        % Расстояние между соседними элементами антенной решетки
        stp (1,1) {mustBeNumeric} = 0.0160 % Шаг элементов, [м]
        
        % prop1 - Режим работы блока
        % Определяет способ расчета фазовых задержек:
        % 'Иммитатор' - для имитации сигналов от цели
        % 'Обработка' - для обработки сигналов под заданным углом
        prop1 {mustBeText} = 'Имитатор' % Расположение элементов
    end

    properties (Constant, Hidden)
        % prop1Set - Допустимые значения для свойства prop1
        % Определяет возможные режимы работы блока
        prop1Set = matlab.system.StringSet({'Имитатор', 'Обработка'})
    end 
  
    properties (Nontunable, Hidden)
        % lambda - Длина волны на рабочей частоте [м]
        % Рассчитывается в setupImpl и используется для вычисления фазовых сдвигов
        lambda (1,1) {mustBeNumeric}
        
        % elemCoord - Координаты элементов антенной решетки [3xN]
        % Матрица 3xN, где каждый столбец содержит координаты (x,y,z)
        % одного элемента решетки. По умолчанию элементы расположены вдоль оси Y
        elemCoord
    end

    methods (Access = protected)

        function setupImpl(obj)
            % setupImpl Инициализация объекта и расчет параметров решетки
            obj.lambda = freq2wavelen(obj.freq); % вычисление длины волны на f0
            
            % Расчет координат элементов с центром решетки в начале координат
            coord = -obj.stp*(obj.N-1)/2 : obj.stp : obj.stp*(obj.N-1)/2; % Координаты элементов решётки
            nVec = [0 1 0]; % Вектор направления расположения элементов (вдоль оси Y)
            obj.elemCoord = nVec'*coord; % 3xN матрица координат
        end

        function psi = stepImpl(obj, input)
            % stepImpl Расчет фазовых задержек для каждого элемента решетки
            % Входной параметр input зависит от режима работы:
            %   - для 'Иммитатор': trgtPos - вектор положения цели [x, y, z]
            %   - для 'Обработка': ang - угол прихода сигнала [градусы]
            % Выход: psi - вектор фазовых задержек для N элементов
            psi = zeros(1, obj.N);

            switch obj.prop1
                case 'Имитатор'
                    % Режим имитатора: расчет фаз для сигнала от цели
                    trgtPos = input'; % Вектор положения цели
                    k0 = trgtPos./norm(trgtPos); % Единичный вектор направления на цель
                    L = dot(obj.elemCoord, repmat(k0, 1, obj.N)); % Разность хода для каждого элемента
                    psi = 2*pi/obj.lambda * L;  % Фазовый сдвиг для имитации сигнала от цели Nx1
                    
                case 'Обработка'
                    % Режим обработки: расчет фаз для формирования луча
                    % углы отклонения луча
                    phi0 = input; 
                    k0 = [cosd(phi0); sind(phi0); zeros(1, length(phi0))]; % Волновой вектор
                    L = dot(obj.elemCoord, repmat(k0, 1, obj.N)); % Разность хода для каждого элемента
                    psi = (-2*pi/ obj.lambda * L );  % Фазовый сдвиг для компенсации при обработке
            end
        end
        
        % Настройка имени блока
        function icon = getIconImpl(obj)
            % getIconImpl Определяет текст, отображаемый на блоке в Simulink
            % icon = ["Phase", "Delay", string(obj.prop1)]; 
            icon = ["Phase", "Delay", string(obj.prop1)]; % Имя порта для режима имитатора
  
        end

        % Определение имён входных портов 
        function [name] = getInputNamesImpl(obj)
            % getInputNamesImpl Возвращает имя входного порта в зависимости от режима            
            switch obj.prop1
                case 'Имитатор'
                    name = 'trgtPos'; % Имя порта для режима имитатора
                case 'Обработка'
                    name = 'ang'; % Имя порта для режима обработки
            end            
        end

        % Определение имён выходных портов 
        function [name] = getOutputNamesImpl(~)
            % getOutputNamesImpl Возвращает имя выходного порта
            name = 'delay'; % Выходной порт содержит вектор фазовых задержек
        end

        function flag = supportsMultipleInstanceImpl(~)
            % Возвращает значение true, если системный блок может использоваться внутри 
            % блока For Each Subsystem (Simulink)
            flag = true;
        end
    end    
end