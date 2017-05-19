function G = third_octave_filterbank(sr, N, bands)

f = (0:sr/N:sr/2);

wm  = 2*pi*10^3 * (2 .^ (bands/3)); % 20Hz-20kHz bands center freqs
wd = 2^(1/6);
w2 = wm * wd; % Upper bandedge freqs
w1 = wm / wd; % Lower bandedge freqs
ws = 2*pi*sr;

k_i = round(N*w1/ws)+1;
k2 = round(N*w2/ws)+1;
N_i = k2-k_i;
d_i = N./(2*N_i);

l = 3;
G = zeros(length(wm), N/2+1);
for ind_wm = 1:length(wm)
    % Construct freq weights G
    if ind_wm == 1 % No ind_wm-1 this time
        P = round(N*(wm(ind_wm)-w1(ind_wm))/ws)-1; % Antoni, right
    else
        % P = round(N*(wm(ind_wm)-w1(ind_wm))/ws)-1; % Antoni, wrong
        P = round(N*(w1(ind_wm)-wm(ind_wm-1))/ws)-1; % Right, TODO ind_wm = 1
    end
    if P < 1
        warning(['Not enough fft points for analysis at center frequency fm = ' num2str(wm(ind_wm)/2/pi) '. G = 1 at closest frequency fm = ' num2str(f(round(N*wm(ind_wm)/ws)+1)) ' and G = 0 otherwise.']);
        nep(ind_wm) = 1;
        G(ind_wm, round(N*wm(ind_wm)/ws)+1) = 1;
    else
        nep(ind_wm) = 0;
        p = -P:P;
        phi = .5*(p./P+1);
        % We found that inverting cos and sin seemed better
        for ind_l = 1:l
            phi = cos(pi/2*phi);
        end
        G(ind_wm, k_i(ind_wm)+p(1):k_i(ind_wm)+p(end)) = cos(pi/2*phi);
        if ind_wm>1
            G(ind_wm-1, k_i(ind_wm)+p(1):k_i(ind_wm)+p(end)) = sin(pi/2*phi);
        end
    end
end

for ind_wm = 1:length(wm)
    if ~nep(ind_wm)
        for ind_w = 2:size(G, 2)
            if G(ind_wm, ind_w) == 0 && G(ind_wm, ind_w-1) > 0.5
                G(ind_wm, ind_w) = G(ind_wm, ind_w-1);
            end
        end
    end
end
G = G(:, 1:N/2+1);
% figure(1), clf, plot(f,20*log10(G'.^2)), grid on;
% figure(2), clf, plot(f,G'), grid on;
% figure(4), clf, plot(sum(G.^2, 1)); % Partition of unity

end
