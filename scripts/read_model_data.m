function sg = read_model_data(model_folder, tp_num, noise_formular)
filename = "model_" + tp_num.to_string() + ".mat";
fullfilename = fullfile(model_folder, filename);

S = load(fullfilename);
names = fieldnames(S);

if tp_num == tp.TP_NOISE
    read_sg = S.(names{1});
    for i = 1:length(noise_formular)
        sg(:,i) = read_sg(:,noise_formular(i).n_packet);
    end
else
        sg = S.(names{1});
end

end