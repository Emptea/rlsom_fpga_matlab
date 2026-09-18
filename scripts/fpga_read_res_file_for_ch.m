function sg = fpga_read_res_file_for_ch(filename, dims, flag_u32, flag_u220)
% sg имеет размерность 8хMхKxN
% тестовый файл содержит N строк в каждой строке 8 каналов
arguments
    filename string = "test.txt"
    dims (1,2) double = [232, 1]  % [M, K]    
    flag_u32 double = 0
    flag_u220 double = 0
end

% Читаем строки
lines = readlines(filename);
lines = strip(lines);
lines(lines == "") = [];

% Каждая строка содержит 16 чисел по 4 hex-символа
chars = char(lines);

% Разбиваем на группы по 4 символа

if flag_u32
    hex_words = reshape(chars.', 8, []).';
    u32 = uint32(hex2dec(hex_words));
    i32 =  typecast(u32, 'int32');

    sg = double(i32);
elseif (flag_u220)
    %ne parsitsa
    hex_words = reshape(chars.', 4, []).';
    hex_words = hex_words(9:end, :);
    u16 = uint16(hex2dec(hex_words));
    s16 = typecast(u16, 'int16');
    
    % Восстанавливаем пары Re/Im
    re = double(s16(2:2:end));
    im = double(s16(1:2:end));
    ch1 = complex(re(1:2:end), im(1:2:end));
    ch2 = complex(re(2:2:end), im(2:2:end));
    figure; plot_complex(ch1)
    figure; plot_complex(ch2)
    sg = zeros(size(re,1)/2, 2);
    sg(:,1) = ch1;
    sg(:,2) = ch2;
else
    
    hex_words = reshape(chars.', 4, []).';
    % hex -> uint16 -> int16
    u16 = uint16(hex2dec(hex_words));
    s16 = typecast(u16, 'int16');
    
    % Восстанавливаем пары Re/Im
    re = double(s16(2:2:end));
    im = double(s16(1:2:end));
    
    sg = complex(re, im);
end

% В каждой строке было 8 комплексных отсчётов
sg = reshape(sg, dims(1), dims(2), []);

% Возвращаем исходный порядок каналов
sg = squeeze(sg);

end