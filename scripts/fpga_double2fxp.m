function [data_fxp] = fpga_double2fxp(data_d)

data_fxp = round(data_d / 0.0136 * 2^10);

end