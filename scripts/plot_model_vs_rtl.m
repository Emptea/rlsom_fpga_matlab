function plot_model_vs_rtl(model_sg, rtl_sg, bit_error, plot_title, comment)

arguments
    model_sg
    rtl_sg
    bit_error
    plot_title string = ""
    comment string = ""
end

figure();
t = tiledlayout(3,1);

title(t, plot_title, 'Interpreter', 'none', 'FontSize', 10);

ax1 = nexttile;
if isreal(model_sg)
    plot(model_sg(:));
else
    plot([real(model_sg(:)), imag(model_sg(:))]);
end
title('Model', 'Interpreter', 'none');

ax2 = nexttile;
if isreal(rtl_sg)
    plot(rtl_sg(:));
else
    plot([real(rtl_sg(:)), imag(rtl_sg(:))]);
end
title('RTL', 'Interpreter', 'none');

ax3 = nexttile;
plot(bit_error(:));
title("Error " + comment, 'Interpreter', 'none');

linkaxes([ax1, ax2, ax3], 'x');

end