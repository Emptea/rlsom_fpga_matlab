function sg = read_model_data(model_folder, tp_num)

filename = "model_" + tp_num.to_string() + ".mat";
fullfilename = fullfile(model_folder, filename);

S = load(fullfilename);
names = fieldnames(S);
sg = S.(names{1});

end