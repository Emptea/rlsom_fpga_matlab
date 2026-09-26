function [rtl_sg, rtl_hdr] = read_rtl_data(rtl_folder, tp_num)

filename = "rtl_" + tp_num.to_string() + ".mat";
fullfilename = fullfile(rtl_folder, filename);

S = load(fullfilename);
names = fieldnames(S);
rtl_data = S.(names{1});
rtl_sg = rtl_data.data;
rtl_hdr = rtl_data.hdr;

end