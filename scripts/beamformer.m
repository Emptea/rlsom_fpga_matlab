classdef beamformer < matlab.System
% Блок формирования выходного буфера АЦП
% beamformer('param_struct', paramRLSmini);

    properties (Nontunable)
        param_struct       % Структура с параметрами конфигурации системы
        % numChannels (1,1 ) {mustBeNumeric} = 8  % Количество каналов АЦП
    end
    
    % Зависимые свойства (значения берутся из param_struct)
    properties (Dependent = true)
       buffSize            % Размер буфера АЦП
       nSfarRX             % Количество отсчетов для приема дальних целей
       nSnearRX            % Количество отсчетов для приема ближних целей
       iMfarRX             % 
       iMnearRX            % 
    end

    methods
        % Конструктор объекта
        function obj = beamformer(varargin)
            setProperties(obj, nargin, varargin{:})
        end

        % Методы доступа к зависимым свойствам
        function value = get.buffSize(obj)
            value = obj.param_struct.buffSize;
        end

        function value = get.nSfarRX(obj)
            value = obj.param_struct.nSfarRX;
        end

        function value = get.nSnearRX(obj)
            value = obj.param_struct.nSnearRX;
        end

        function value = get.iMfarRX(obj)
            value = obj.param_struct.iMfarRX;
        end
        
        function value = get.iMnearRX(obj)
            value = obj.param_struct.iMnearRX;
        end
    end

    methods (Access = protected)
        function setupImpl(obj)
      
        end

        function [bufFar, bufNear] = stepImpl(obj, phDelay, ADCbuff)
            % stepImpl - Основной алгоритм обработки, вызывается на каждом шаге
                            
            bufFar = ADCbuff(:,obj.iMfarRX).*conj(exp(1i*phDelay)');
            bufFar = sum(bufFar,1);

            bufNear = ADCbuff(:,obj.iMnearRX).*conj(exp(1i*phDelay)');
            bufNear = sum(bufNear,1);
        end
        

        function resetImpl(obj)
            % resetImpl - Сбрасывает состояние объекта к начальному
            % Вызывается при сбросе симуляции или при вызове reset()
            
        end

        % Определение фиксированности размера выходных сигналов
        function [out, out2] = isOutputFixedSizeImpl(obj)
            out = true;     % Первый выход имеет фиксированный размер
            out2 = true;    % Второй выход имеет фиксированный размер
        end

        % Определение комплексности выходных сигналов
        function [out, out2] = isOutputComplexImpl(obj)
            out = true;     % Первый выход - комплексный
            out2 = true;    % Второй выход - комплексный
        end

        % Определение типа данных выходных сигналов
        function [out, out2] = getOutputDataTypeImpl(obj)
            out = "double";     % Тип данных первого выхода
            out2 = "double";    % Тип данных второго выхода
        end

        function [out,out2] = getOutputSizeImpl(obj)
            % Return size for each output port
            % sz2 = propagatedInputSize(obj, 2);
            % nChADC = sz2(1);

            out = [1 obj.nSfarRX];
            out2 = [1 obj.nSnearRX];

            % Example: inherit size from first input port
            % out = propagatedInputSize(obj,1);
        end

        function flag = supportsMultipleInstanceImpl(~)
            % supportsMultipleInstanceImpl - Проверка поддержки множественных экземпляров
            % Определяет, может ли блок использоваться внутри For Each Subsystem
            
            flag = true;  % Поддерживает множественные экземпляры (можно использовать в циклах)
        end

        
    end
end