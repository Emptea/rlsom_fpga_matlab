filename = "data/rx_dump/3_rx_dump.hex";
sg = fpga_read_test_file(filename, [234, 1]);

for ch = 1:8x
    figure;
    plot_complex(permute(sg(ch,3:end, :), [2 3 1]))
    sgtitle("SDR signal for ch" + (ch-1))
end
