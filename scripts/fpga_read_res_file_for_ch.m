function [data, hdr] = fpga_read_res_file_for_ch(filename)

n_fft = 512;
n_far_and_near_and_zeros = 164;
n_far_and_near = 141;
n_hdr_lines = 6;

%% Чтение
lines = readlines(filename);
lines = strip(lines);
lines(lines == "") = [];

%%
sgs = [];

idx_start_packet = 1;
idx_packet = 1;
while idx_start_packet < length(lines)    
    hdr_range = idx_start_packet:(idx_start_packet + n_hdr_lines - 1);
    hdr = fpga_parse_hdr(lines(hdr_range));
    
    %% Определяем формат контрольной точки
    switch hdr.tp
        case tp.TP_BYPASS
            data_size = 232;
            is_u32 = false;
        case {tp.TP_CUT, tp.TP_FAPCH, tp.TP_LOU}
            data_size = n_far_and_near_and_zeros;
            is_u32 = false;
        case tp.TP_SF
            data_size = n_far_and_near;
            is_u32 = false;
        case {tp.TP_DDR, tp.TP_FFT, tp.TP_WEIGHT_OUT}
            data_size = n_fft;
            is_u32 = false;
        case tp.TP_MAX
            data_size = n_far_and_near;
            is_u32 = true;
        case tp.TP_FIND
            data_size = 5 * n_far_and_near;
            is_u32 = true;
        case {tp.TP_RANK, tp.TP_APU}
            data_size = n_far_and_near;
            is_u32 = true;
        case tp.TP_FAPCH_COEFFS
            data_size = 8;
            is_u32 = false;
        otherwise
            error("Unsupported test point: TP%d", double(hdr.tp));
    end
    
    idx_start_data = idx_start_packet + n_hdr_lines;
    data_range = idx_start_data:(idx_start_data + data_size - 1);
    data_chars = char(lines(data_range));
    
    if is_u32
        
        % 8 hex символов = uint32/int32
        hex_words = reshape(data_chars.', 8, []).';
        
        u32 = uint32(hex2dec(hex_words));
        sg = double(typecast(u32, 'int32'));
        
    else
        
        % 4 hex символа = uint16/int16
        hex_words = reshape(data_chars.', 4, []).';
        
        u16 = uint16(hex2dec(hex_words));
        s16 = typecast(u16, 'int16');
        
        % Формируем комплексные отсчёты
        im = double(s16(1:2:end));
        re = double(s16(2:2:end));
        
        sg = complex(re, im);
    end    
    
    if idx_packet == 1
        hdrs = hdr;
    else
        hdrs(idx_packet) = hdr;
    end
    sgs(:, idx_packet) = sg;
    idx_packet = idx_packet + 1;
    idx_start_packet = data_range(end) + 1;
    
end

hdr = hdrs;
data = sgs;

end