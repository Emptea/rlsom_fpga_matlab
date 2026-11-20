function [data, hdr, work_packet] = fpga_read_res_file_for_ch(filename)

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
hdrs = struct([]);
work_packet = struct([]);

idx_start_packet = 1;
idx_packet = 1;
formular_cnt = 0;
formulars = struct([]);
noise_formulars = struct([]);
posthdrs = struct([]);
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
        case {tp.TP_SF, tp.TP_MTI}
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
        case tp.TP_WORK
            data_size = 17;
            is_u32 = false;
        case tp.TP_PU_IN
            data_size = 141*2;
            is_u32 = true;
        otherwise
            error("Unsupported test point: TP%d", double(hdr.tp));
    end
    
    idx_start_data = idx_start_packet + n_hdr_lines;
    data_range = idx_start_data:(idx_start_data + data_size - 1);
    data_chars = char(lines(data_range));
    
    if(hdr.tp == tp.TP_WORK)
        hex_words = reshape(data_chars.', 8, []).';
        
        u32 = uint32(hex2dec(hex_words));
        noise_FAP = double(typecast(u32(2:9), 'int32'));
        noise_LOU = double(typecast(u32(10:17), 'int32'));
        sg = [noise_FAP; noise_LOU]; % noise_FAP[8], noise_LOU[8]
        

        % Each signed 24-bit coefficient occupies a 32-bit word.
        compens_start = idx_start_data + data_size;
        compens_words = uint32(hex2dec(lines(compens_start:compens_start + 16)));
        coeffs = double(bitand(compens_words(2:17), uint32(16777215)));
        coeffs(coeffs >= 2^23) = coeffs(coeffs >= 2^23) - 2^24;
        compens_formular = struct('n_packet', compens_words(1), ...
            're_raw', coeffs(1:2:end), 'im_raw', coeffs(2:2:end), ...
            'coefficients', complex(coeffs(1:2:end), coeffs(2:2:end)) / 2^14);
        data_size = data_size + 17;
        idx_start_posthdr = idx_start_data + data_size;
        posthdr_size = 2;
        data_size  = data_size + posthdr_size;
        posthdr_range = idx_start_posthdr: (idx_start_posthdr + posthdr_size - 1);
        work_posthdr = fpga_parse_posthdr(lines(posthdr_range));
        if idx_packet == 1
            noise_formulars = struct( ...
                'n_packet', u32(1), ...
                'noise_FAP', noise_FAP, ...
                'noise_LOU', noise_LOU);
            
        else
            noise_formulars(idx_packet) = struct( ...
                'n_packet', u32(1), ...
                'noise_FAP', noise_FAP, ...
                'noise_LOU', noise_LOU);
        end
        n_packs = work_posthdr.n_formulars;
        packet_formulars = struct([]);
        for i = 1:n_packs
            formular_cnt = formular_cnt + 1;
            formular_sz = 4;
            formular_offset = idx_start_posthdr + posthdr_size + (i - 1)*(formular_sz);
            formular_range = formular_offset:(formular_offset + formular_sz - 1);
            if formular_cnt == 1
                formulars = fpga_parse_work_formular(lines(formular_range));
            else
                formulars(formular_cnt) =  fpga_parse_work_formular(lines(formular_range)); 
            end
            data_size = data_size + formular_sz;
            if i == 1
                packet_formulars = formulars(formular_cnt);
            else
                packet_formulars(i) = formulars(formular_cnt);
            end
        end
        ranges_start = idx_start_data + data_size;
        assert(ranges_start <= numel(lines), 'Missing TP_WORK range header.');
        dnum = hex2dec(lines(ranges_start));
        assert(dnum <= 141 && ranges_start + dnum <= numel(lines), ...
            'Invalid or truncated TP_WORK range list.');
        ranges = struct('Dnum', uint32(dnum), ...
            'values', uint32(hex2dec(lines(ranges_start + (1:dnum)))));
        decoded_packet = struct('source', uint32(0), ...
            'noise_formular', noise_formulars(idx_packet), ...
            'compens_formular', compens_formular, ...
            'formulars', struct('packet_number', uint32(work_posthdr.packet_number), ...
                'n_formulars', uint32(n_packs), 'items', packet_formulars), ...
            'ranges', ranges);
        if idx_packet == 1
            work_packet = decoded_packet;
        else
            work_packet(idx_packet) = decoded_packet;
        end
        data_size = data_size + 1 + dnum;
        data_range = idx_start_data:(idx_start_data + data_size - 1);
    elseif is_u32
        
        % 8 hex символов = uint32/int32
        hex_words = reshape(data_chars.', 8, []).';
        
        u32 = uint32(hex2dec(hex_words));
        sg = double(typecast(u32, 'int32'));

        if (hdr.tp == tp.TP_PU_IN)
            sg_out = double(typecast(u32(1:2:end), 'int32'));
            rank_out = double(typecast(u32(2:2:end), 'int32'));
            sg = [sg_out; rank_out];
        end
        
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