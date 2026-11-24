function T = parse_rx_headers(filename)
%PARSE_RX_HEADERS Decode RX header log: six hexadecimal uint32 words per record.
%   T = parse_rx_headers('rx_headers.log')
%
    if nargin < 1
        [name, folder] = uigetfile({'*.log;*.hex;*.txt', 'RX header logs'});
        if isequal(name, 0)
            T = table();
            return;
        end
        filename = fullfile(folder, name);
    end

    fid = fopen(filename, 'r');
    if fid < 0
        error('Cannot open file: %s', filename);
    end
    cleanup = onCleanup(@() fclose(fid));
    data = textscan(fid, '%s', 'Whitespace', ' \t\r\n');
    words = data{1};

    if mod(numel(words), 6) ~= 0
        error('Invalid log: expected 6 hexadecimal words per header.');
    end

    w = reshape(uint32(hex2dec(words)), 6, []);

    del = "0x" + string(dec2hex(w(1, :).', 8)) + string(dec2hex(w(2, :).', 8));
    packet_number = w(3, :).';
    timestamp = bitor(bitshift(uint64(w(5, :).'), 32), uint64(w(4, :).'));

    flags = w(6, :).';
    channel = uint8(bitand(flags, uint32(7)));
    range = uint16(bitand(bitshift(flags, -3), uint32(8191)));
    tp = uint16(bitshift(flags, -16));

    T = table(del, packet_number, timestamp, channel, range, tp);
end
