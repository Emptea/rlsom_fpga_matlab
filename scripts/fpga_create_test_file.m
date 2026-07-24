function fpga_create_test_file(sg, filename)
arguments
    sg (8, :, :, :) double
    filename string = "test.txt"
end

sg_reverse = sg(end:-1:1, :, :);
sg_s16 = int16(reshape([real(sg_reverse(:)), imag(sg_reverse(:))]', [], 1));
arr_char = reshape(dec2hex(sg_s16, 4)', 16 * 4, []);
arr_string = string(arr_char');
writelines(arr_string, filename)

end