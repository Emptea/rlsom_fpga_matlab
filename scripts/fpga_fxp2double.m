function [data_d] = fpga_fxp2double(data_fxp)
data_d = data_fxp / (2^12 - 1);
end