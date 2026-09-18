function sg = read_board_data(out_folder, tp_num, range_gate, hdr_sz)
%READ_BOARD_DATA Read FPGA board output data for a specified test point.
%
% Inputs:
%   out_folder - Folder containing the hexadecimal output files
%   tp_num     - Test-point enumeration value, such as tp.TP_FIND
%   range_gate - Selected range gate
%   hdr_sz     - Header size
%
% Output:
%   sg         - Board signal data

    sg = [];
    tp_value = double(tp_num);

    switch tp_num
    case {tp.TP_MAX, tp.TP_FIND, tp.TP_RANK, tp.TP_APU, tp.TP_FAPCH_COEFFS}
        % Test points above TP_FFT contain only channel 0.
        ch = 0;

        hexname = out_folder ...
            + "/out_tp" + tp_value ...
            + "_ch" + ch ...
            + "_rg" + range_gate + ".hex";

        sg = fpga_txt2mat_for_ch(hexname);

        disp(sg(ch+1, hdr_sz, 1))

    otherwise
        % Other test points contain up to eight channels.
        for ch = 0:7
            try
                hexname = out_folder ...
                    + "/out_tp" + tp_value ...
                    + "_ch" + ch ...
                    + "_rg" + range_gate + ".hex";

                sg(ch+1,:,:) = fpga_txt2mat_for_ch(hexname);

                disp(sg(ch+1, hdr_sz, 1))

            catch exception
                disp("Found no file for channel " + ch)
                disp(exception.message)
            end
        end
    end
end