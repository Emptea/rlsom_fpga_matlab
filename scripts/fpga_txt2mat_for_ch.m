function sg = fpga_txt2mat_for_ch(filename)

fprintf('Обработка файла: %s\n', filename);

[folder, name, ext] = fileparts(filename);
file = string(name) + string(ext);
out_filename = folder + "/" + name + ".mat";
hdr_sz = 6;
n_sf = 40;
n_fft = 512;
n_far_and_need = 164; % количество отчетов ближней и дальней зонны в сумме
% Определяем тип файла
if contains(file, "tp10")
    sg = fpga_read_res_file_for_ch(filename, [n_far_and_need + hdr_sz, 1], 1);
    tp10_rank = fpga_fxp2double(sg);
    save(out_filename, "tp10_rank"); 
elseif contains(file, "tp11")
    sg = fpga_read_res_file_for_ch(filename, [n_far_and_need + hdr_sz, 1], 1);
    tp11_apu = fpga_fxp2double(sg);
    save(out_filename, "tp11_apu"); 
elseif contains(file, "tp12")
    sg = fpga_read_res_file_for_ch(filename, [8 + hdr_sz, 1]);
    tp12_fapch_coeffs = fpga_fxp2double(sg);
    save(out_filename, "tp12_fapch_coeffs"); 
elseif contains(file, "tp2")
    sg = fpga_read_res_file_for_ch(filename, [n_far_and_need + hdr_sz, 1]);
    tp2_cut = fpga_fxp2double(sg);
    save(out_filename, "tp2_cut");
elseif contains(file, "tp3")
    sg = fpga_read_res_file_for_ch(filename, [n_far_and_need + hdr_sz, 1]);
    tp3_fap = fpga_fxp2double(sg);
    save(out_filename, "tp3_fap");
elseif contains(file, "tp4")
    sg = fpga_read_res_file_for_ch(filename, [n_far_and_need + hdr_sz, 1]);
    tp4_lou = fpga_fxp2double(sg);
    save(out_filename, "tp4_lou");    
elseif contains(file, "tp5")
    sg = fpga_read_res_file_for_ch(filename, [141 + hdr_sz, 1]);
    tp5_sf = fpga_fxp2double(sg);
    save(out_filename, "tp5_sf"); 
elseif contains(file, "tp6")
    sg = fpga_read_res_file_for_ch(filename, [n_fft + hdr_sz, 1]);
    tp6_ddr = fpga_fxp2double(sg);
    save(out_filename, "tp6_ddr");
elseif contains(file, "tp7")
    sg = fpga_read_res_file_for_ch(filename, [n_fft + hdr_sz, 1]);
    tp7_fft = fpga_fxp2double(sg);
    save(out_filename, "tp7_fft");
elseif contains(file, "tp8")
    sg = fpga_read_res_file_for_ch(filename, [141 + hdr_sz, 1], 1);
    tp8_max = fpga_fxp2double(sg);
    save(out_filename, "tp8_max"); 
elseif contains(file, "tp9")
    sg = fpga_read_res_file_for_ch(filename, [5 * 141 + hdr_sz, 1], 1);
    tp9_find = fpga_fxp2double(sg);
    save(out_filename, "tp9_find"); 
elseif contains(file, "tp1")
    sg = fpga_read_res_file_for_ch(filename, [232 + hdr_sz, 1]);
    tp1_fd = fpga_fxp2double(sg);
    save(out_filename, "tp1_fd");
else
    return;
end

fprintf('Создание файла: %s\n', out_filename);
end



