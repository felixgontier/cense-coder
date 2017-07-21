function w = sroexfilter(f)
% Simplified rounded exponential (ro-ex) filterbank (with equal
% band-importance critical bands)

% Zwicker & Terhardt, Analytical expressions for critical-band rate and critical bandwidth as a function of frequency, 1980
% ANSI S3.5-1997
q = [.35 .45 .57 .7 .84 1 1.17 1.37 1.6 1.85 2.15 2.5 2.9 3.4 4 4.8 5.8];

%f_l = [.3 .4 .51 .63 .77 .92 1.08 1.27 1.48 1.72 2 2.32 2.7 3.15 3.7 4.4 5.3];
%f_u = [.4 .51 .63 .77 .92 1.08 1.27 1.48 1.72 2 2.32 2.7 3.15 3.7 4.4 5.3 6.4];
%erb = (f_u-f_l);
% Moore & Glasberg, Suggested formulae for calculating auditory-filter bandwidths and excitation patterns, 1983
erb = 24.7*(4.37*q+1);
% Glasberg & Moore, Derivation of auditory filter shapes from notched-noise data, 1990
%erb = 6.23*q.^2+93.39*q+28.52;

p = 4*1000*q./erb;
g = abs(1-repmat(f, 1, length(q))./repmat(q, length(f), 1));

% Simplified ro-ex filter bank
w = (1+repmat(p, length(f), 1).*g).*exp(-repmat(p, length(f), 1).*g);

end