function [buffOut, Y, X, K] = phAutoTune(buffIn, A)
iMpat = 188:227;
Y = buffIn(:,iMpat);

X = mean(Y,2);

K = A*conj(X)./abs(X).^2;

buffOut = K.*buffIn;
