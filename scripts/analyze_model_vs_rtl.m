function analyze_model_vs_rtl(tp_num, model_sg, rtl_sg, force_plot)
arguments
    tp_num
    model_sg
    rtl_sg
    force_plot logical = false
end

[model_sg, rtl_sg] = align_packets(model_sg, rtl_sg);

switch tp_num
    case {tp.TP_BYPASS, tp.TP_CUT, tp.TP_FAPCH, tp.TP_LOU, tp.TP_SF, tp.TP_MTI}
        channels = 0:7;
        
    case {tp.TP_DDR, tp.TP_FFT, tp.TP_WEIGHT_OUT}
        channels = 0:7;
        if numel(size(model_sg)) == 4
            model_sg = permute(model_sg, [1, 3, 2, 4]);   
        end
        if numel(size(rtl_sg)) == 4            
            rtl_sg = permute(rtl_sg, [1, 3, 2, 4]);
        end
        
    case {tp.TP_MAX, tp.TP_FIND, tp.TP_RANK, tp.TP_APU}
        channels = 0;
        
    otherwise
        error("Unsupported test: %s", tp_num.to_string());
end

if numel(channels) > 1
    for ch = channels
        model_sg_ch = model_sg(ch + 1, :).';
        rtl_sg_ch = rtl_sg(ch + 1, :).';
        
        name = tp_num.to_string() + " ch" + ch;
        analyze_signals(model_sg_ch, rtl_sg_ch, name, force_plot);
    end
else
    analyze_signals(model_sg, rtl_sg, tp_num.to_string(), force_plot);
end

end


function analyze_signals(model_sg, rtl_sg, name, force_plot)
arguments
    model_sg
    rtl_sg
    name string
    force_plot logical = false
end

bit_error = abs(model_sg - rtl_sg);

mean_error = mean(bit_error(:));
[max_error, idx_max] = max(bit_error(:));

if max_error > 3
    status = "✗";
else
    status = "✓";
end

comment = sprintf("| %s | mean err: %10.4g | max err: %10.4g | pos err: %8d |", ...
    status, mean_error, max_error, idx_max);

fprintf("%-15s%s\n", name, comment);

if status == "✗" || force_plot
    plot_model_vs_rtl(model_sg, rtl_sg, bit_error, name, comment);
end

end