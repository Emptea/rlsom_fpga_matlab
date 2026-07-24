function fpga_mat2txt_batch(folder)
arguments
    folder string = "data";
end

%% поиск файлов
pattern = fullfile(folder, '**', "*tp*.mat");
files = dir(pattern);

if isempty(files)
    fprintf('Файлы не найдены.\n');
    return;
end
fullpaths = fullfile({files.folder}, {files.name});

for i = 1:length(fullpaths)
    filename = string(fullpaths{i});
    fpga_mat2txt(filename);
end

end





