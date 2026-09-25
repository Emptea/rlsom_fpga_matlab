function tp_mti = calc_mti(tp_sf, n_taps)
arguments
    tp_sf (:,141,:)
    n_taps {mustBeInteger, mustBeInRange(n_taps, 1, 10)} = 6
end

tp_mti = tp_sf;
tp_mti(1,102:141,n_taps+1:end) = tp_mti(1,102:141,n_taps+1:end) - tp_mti(1,102:141,1:end - n_taps);

end
