function [data_fxp] = fpga_double2fxp(data_d)

data_fxp = round(data_d * (2^12 - 1));

end