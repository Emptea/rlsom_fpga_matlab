function [data_d] = fpga_fxp2double(data_fxp)
data_d = data_fxp * 0.0136 / 2^10;
end