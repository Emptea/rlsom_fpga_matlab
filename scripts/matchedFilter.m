function Z = matchedFilter(txSig, rxSig)
% Согласованная фильтрация
Z = conv(rxSig, conj(flip(txSig)),"same");
