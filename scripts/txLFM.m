classdef txLFM < matlab.System
% txLFM Генератор сигнала с линейной частотной модуляцией (ЛЧМ)
% Формирует комплексную огибающую ЛЧМ сигнала для различных режимов работы
% (дальняя/ближняя зона) с разным количеством отсчетов
    
    properties (Nontunable)
        sPeriod (1,1) {mustBeNumeric, mustBeNonempty} % Длительность кванта, [сек]
        freqDev (1,1) {mustBeNumeric, mustBeNonempty} % Девиация частота, [Гц]
        
        % prop1 - Режим работы генератора
        % Определяет количество отсчетов в сигнале:
        % 'Дальняя зона' - 40 отсчетов
        % 'Ближняя зона' - 6 отсчетов
        prop1 {mustBeText} = 'Дальняя зона' % Расположение элементов
    end

    properties (Nontunable, Hidden)
        % nSamp - Количество отсчетов в ЛЧМ сигнале
        % Зависит от выбранного режима работы
        nSamp (1,1)        
    end

    % Pre-computed constants or internal states
    properties (Access = private)
        % prop1Set - Допустимые значения для свойства prop1
        % Определяет возможные режимы работы генератора
        prop1Set = matlab.system.StringSet({'Дальняя зона', 'Ближняя зона'})
    end

    methods (Access = protected)
        function setupImpl(obj)
            % setupImpl Инициализация объекта и настройка параметров
            % Устанавливает количество отсчетов в зависимости от режима работы
            
            switch obj.prop1
                case 'Дальняя зона'
                    obj.nSamp = 40; % Больше отсчетов для дальней зоны (высокое разрешение)
                case 'Ближняя зона'
                    obj.nSamp = 6;  % Меньше отсчетов для ближней зоны
            end
        end

        function txSig = stepImpl(obj)
            % stepImpl Генерация ЛЧМ сигнала
            % Возвращает комплексную огибающую ЛЧМ сигнала в виде вектора-столбца
            
            sIdx = 0:obj.nSamp-1;  % Вектор индексов отсчетов от 0 до nSamp-1
            tVec = sIdx * obj.sPeriod; % Дискретные моменты времени

            % Расчет фазовой модуляции для ЛЧМ сигнала
            deltaOmega = 2*pi*obj.freqDev;  % Девиация частоты в радианах/с
            
            % Формула фазы ЛЧМ сигнала:
            % phase = (девиация/(2*длительность)) * t^2 - (девиация/2) * t
            % Обеспечивает линейное изменение частоты во времени
            phase = (deltaOmega/(2*obj.nSamp*obj.sPeriod))*tVec.^2 - (deltaOmega/2)*tVec;

            % Формирование комплексной огибающей ЛЧМ сигнала
            txSig = zeros(obj.nSamp,1); % Предварительное выделение памяти
            txSig = exp(-1i*phase);      % Комплексная экспонента с рассчитанной фазой
        end

        function icon = getIconImpl(obj)
            % getIconImpl Определяет текст, отображаемый на блоке в Simulink
            % Отображает название блока и сокращенное обозначение зоны
            
            switch obj.prop1
                case 'Дальняя зона'
                    icon =  ["txLFM", 'ДЗ']; % ДЗ - дальняя зона
                case 'Ближняя зона'
                    icon =  ["txLFM", 'БЗ']; % БЗ - ближняя зона
            end
        end

        function name = getOutputNamesImpl(~)
            % getOutputNamesImpl Возвращает имя выходного порта
            % Пустая строка означает, что имя порта не отображается
            name = '';
        end

        function flag = supportsMultipleInstanceImpl(~)
            % supportsMultipleInstanceImpl Проверка поддержки множественных экземпляров
            % Возвращает значение true, если системный блок может использоваться внутри 
            % блока For Each Subsystem (Simulink)
            flag = true; % Поддерживает множественные экземпляры
        end
    end
end