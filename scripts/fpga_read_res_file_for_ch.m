function sg = fpga_read_res_file_for_ch(filename, dims)
% sg имеет размерность 8хMхKxN
% тестовый файл содержит N строк в каждой строке 8 каналов
arguments
    filename string = "test.txt"
    dims (1,2) double = [232, 1]  % [M, K]    
end

% Читаем строки
lines = readlines(filename);
lines = strip(lines);
lines(lines == "") = [];

% Каждая строка содержит 16 чисел по 4 hex-символа
chars = char(lines);

% Разбиваем на группы по 4 символа
hex_words = reshape(chars.', 4, []).';

% hex -> uint16 -> int16
u16 = uint16(hex2dec(hex_words));
s16 = typecast(u16, 'int16');

% Восстанавливаем пары Re/Im
re = double(s16(1:2:end));
im = double(s16(2:2:end));

sg = complex(re, im);

% В каждой строке было 8 комплексных отсчётов
sg = reshape(sg, dims(1), dims(2), []);

% Возвращаем исходный порядок каналов
sg = squeeze(sg);

end