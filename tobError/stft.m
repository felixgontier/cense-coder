function x_stft = stft(x, l_win, l_hop, wintype, zero_pad, winparam)

if nargin < 4
    wintype = 'hamming'; % Default window: hamming
end
if nargin < 3
    l_hop = round(0.5*l_win); % Default overlap: 50%
end

n_win = 1+(length(x)-l_win)/l_hop; % Number of windows

%% Window generation
switch wintype % Other windows to implement
    case 'hamming'
        w = hamming(l_win, 'periodic');
    case 'hanning'
        w = hanning(l_win, 'periodic');
    case 'blackmanharris'
        w = blackmanharris(l_win, 'periodic');
    case 'bartlett'
        w = bartlett(l_win);
    case 'bartletthann'
        w = barthannwin(l_win);
    case 'gaussian'
        w = gausswin(l_win);
    case 'kaiser'
        w = kaiser(l_win, 0.25);
    case 'tukey01'
        w = tukeywin(l_win, 0.1);
    case 'tukey02'
        w = tukeywin(l_win, 0.2);
    case 'tukey03'
        w = tukeywin(l_win, 0.3);
    case 'tukey04'
        w = tukeywin(l_win, 0.4);
    case 'tukey05'
        w = tukeywin(l_win, 0.5);
    case 'tukey06'
        w = tukeywin(l_win, 0.6);
    case 'tukey07'
        w = tukeywin(l_win, 0.7);
    case 'tukey08'
        w = tukeywin(l_win, 0.8);
    case 'tukey09'
        w = tukeywin(l_win, 0.9);
    case 'rect'
        w = ones(l_win, 1);
end

if zero_pad; n_pad = 2^(ceil(log2(l_win)))-l_win; else n_pad = 0; end; % Zero pad to next power of 2
%% STFT
x_stft = zeros(l_win+n_pad, n_win);
for indwin = 1:n_win
    
    %% Windowing
    x_win = [x((indwin-1)*l_hop+1:(indwin-1)*l_hop+l_win).*w; zeros(n_pad, 1)];
    %% FFT
    x_stft(:, indwin) = fft(x_win); % FFT magnitude
end

x_stft = x_stft(1:end/2+1,:);

end

