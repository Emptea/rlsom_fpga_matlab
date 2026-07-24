comp_coeff_str = '9d8aec4facfaf22aa5e4ef9e70a4eb86acfaf22aacfaf22a4f73b9629394e7e8';
comp_vec_str = reshape(comp_coeff_str, 4, [])';

comp_vec = double(typecast(uint16(hex2dec(comp_vec_str)), 'int16'));
comp_vec_cmplx = complex(comp_vec(1:2:end), comp_vec(2:2:end)) / (2^14 - 1);
comp_vec_cmplx = comp_vec_cmplx(end:-1:1);