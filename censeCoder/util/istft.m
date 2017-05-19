function x = istft(x_stft, l_frame, l_hop, wintype)

if nargin < 3
    wintype = 'hamming'; % Default window: hamming
end

n_win = size(x_stft, 2);
l_win = l_frame;%(size(x_stft, 1)-1)*2;
x_stft = [x_stft; conj(flipud(x_stft(2:end-1, :)))];
%% Window generation
switch wintype % Other windows to implement
    case 'hamming'
        w = hamming(l_win, 'periodic');
    case 'hanning'
        w = hanning(l_win, 'periodic');
    case 'rect'
        w = ones(l_win, 1);
end

%% Inverse STFT
x = zeros(l_win+(n_win-1)*l_hop, 1);
w_norm = zeros(size(x));
for indwin = 1:n_win
    indt = (indwin-1)*l_hop; % Start time of the current window
    x_temp = x_stft(:, indwin);
    x_temp = real(ifft(x_temp));
    x(indt+1:indt+l_win) = x(indt+1:indt+l_win) + x_temp(1:l_win);%.*w;
    w_norm(indt+1:indt+l_win) = w_norm(indt+1:indt+l_win)+w;%.^2;
end
x = x./w_norm;

end

