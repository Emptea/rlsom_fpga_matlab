function zone = calc_noise_zone(sg, noise_formular)

sg = sg(:,86:101,:);
sg_sum_sq = sum(abs(sg).^2, 2);

zone_all = permute(sg_sum_sq,[1 3 2]) / 16;

for i = 1:length(noise_formular)
    zone(:,i) = zone_all(:,noise_formular(i).n_packet+1);
end
% zone(:,length(noise_formular)) = zone_all(noise_formular(end).n_packet);
% % % zone = zone_all(:, 20:20:end);
end