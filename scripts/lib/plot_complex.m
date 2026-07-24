function plot_complex(varargin)

% Обработка аргументов
if nargin == 1
    sigs_c = varargin{1};
    x = 1:size(sigs_c, 1); % значение по умолчанию
elseif nargin == 2
    x = varargin{1};
    sigs_c = varargin{2};
else
    error('Неверное число аргументов');
end

% arguments
    
% end
sigs_c = reshape(sigs_c, size(sigs_c, 1), []);
subplot(2,1,1)
plot(x, real(sigs_c));
subplot(2,1,2);
plot(x, imag(sigs_c));

linkaxes;


end