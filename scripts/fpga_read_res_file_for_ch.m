function [data, hdr, formular] = fpga_read_res_file_for_ch(filename)

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
formular_cnt = 0;
formular = struct([]);
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
            data_size = n_far_and_near_and_zeros;
            is_u32 = true;
        case tp.TP_FAPCH_COEFFS
            data_size = 8;
            is_u32 = false;
        case tp.TP_WORK
            data_size = 2;
            is_u32 = false;
        otherwise
            error("Unsupported test point: TP%d", double(hdr.tp));
    end
    
    idx_start_data = idx_start_packet + n_hdr_lines;
    data_range = idx_start_data:(idx_start_data + data_size - 1);
    data_chars = char(lines(data_range));
    
    if(hdr.tp == tp.TP_WORK)
        work_posthdr = fpga_parse_posthdr(lines(data_range));
        n_packs = work_posthdr.n_formulars;
        for i = 1:n_packs
            formular_cnt = formular_cnt + 1;
            formular_sz = 4;
            formular_offset = idx_start_data + data_size + (i - 1)*(formular_sz);
            formular_range = formular_offset:(formular_offset + formular_sz - 1);
            if formular_cnt == 1
                formular = fpga_parse_work_formular(lines(formular_range));
            else
                formular(formular_cnt) =  fpga_parse_work_formular(lines(formular_range)); 
            end
            data_size = data_size + formular_sz;
        end
        sg = 1;
        data_range = idx_start_data:(idx_start_data + data_size - 1);
    elseif is_u32
        
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
        if(hdr.tp == tp.TP_WORK)
            posthdrs = work_posthdr;
        end
    else
        hdrs(idx_packet) = hdr;
        if(hdr.tp == tp.TP_WORK)
            posthdrs(idx_packet) = work_posthdr;
        end
    end
    sgs(:, idx_packet) = sg;
    idx_packet = idx_packet + 1;
    idx_start_packet = data_range(end) + 1;
    
end

hdr = hdrs;
data = sgs;

end