function work_posthdr = fpga_parse_posthdr(posthdr_hex)

packet_number = hex2dec(posthdr_hex(1));
n_formulars = hex2dec(posthdr_hex(2));


work_posthdr = struct( ...
    'packet_number', packet_number, ...
    'n_formulars', n_formulars);

end