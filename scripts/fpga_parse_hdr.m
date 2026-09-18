function hdr = fpga_parse_hdr(hdr_hex)

del = hex2dec(hdr_hex(1)) * 2^32 + hex2dec(hdr_hex(2));
packet_number = hex2dec(hdr_hex(3));
timestamp_high = uint64(hex2dec(hdr_hex(5)));
timestamp_low  = uint64(hex2dec(hdr_hex(4)));
timestamp = bitshift(timestamp_high, 32) + timestamp_low;
last_word = uint32(hex2dec(hdr_hex(6)));
channel = uint8(bitand(last_word, 0x7u32));
range = uint16(bitand(bitshift(last_word, -3), 0x1FFFu32));
tp_num = uint16(bitshift(last_word, -16));

hdr = struct( ...
    'del',           del, ...
    'packet_number', packet_number, ...
    'timestamp',     timestamp, ...
    'channel',       channel, ...
    'range',         range, ...
    'tp',            tp_num);

end