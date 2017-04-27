function w = RoundedExponential(f_center, f, I_dB)
% This software was written by Preeti Rao at the
% Institute for Perception Research (IPO) in 1999, and
% adapted by Dik Hermes, Human-Technology Interaction group,
% Eindhoven University of Technology in 2009.
%
% The function RoundedExponential computes the intensity transfer
% function of a "roex" filter. The scalar f_center represents
% the vector of filter center frequencies and I_dB the input
% intensities levels of the input. The vector f
% contains the frequencies for which the output of the
% roex-filter is calculated.
% A roex filter can be represented as (1+p*g)*exp(-p*g), in which g
% is normalized frequency and p represents the slope of the filter.
% The minumum input of each filter is at least min_level_db, 20 dB.
%
% The rounded exponential filter shapes are calculated
% according to:
%
% [1] Moore B.C.J. & Glasberg B.R. (1987) Formulae describing
% frequency selectivity as a function of frequency and
% level, and their use in calculating excitation patterns.
% Hearing Research 28, 209-225.
%
% [2] Glasberg B.R. & Moore B.C.J. (1990)
% Derivation of auditory filter shapes from notched-noise data.
% Hearing Research 47, 103-128.
%
% [3] Moore B.C.J., Glasberg B.R. & Baer T. (1997),
% A model for the prediction of thresholds, loudness,
% and partial loudness.
% J. Audio Eng. Soc. 45(4), 224-240.

min_level_db = 20;
fk = f_center/1000;
I_dB = max(min_level_db, I_dB);

% Calculate the ERB at frequencies "fk" according
% to Eq. 3 in [2]
erb = 24.7*(4.37*fk+1);

% Calculation of the upper and lower p-values, pu and pl
erbk = 24.7*(4.37*1+1); % ERB for 1 kHz
pk51 = (4*1000)/erbk; % p at 1 kHz for 51 dB, where pu = pl.
p51 = 4*f_center./erb;
% Next Eq. 8 in [1] or Eq. 5 in [2] are applied with 0.38 replaced
% by 0.35 following [3]. Moreover, [3] supposes pu to be constant
% with level.
pl = p51-0.35*(I_dB-51)*(p51/pk51);
pu = p51;

% pl and pu cannot be negative
pl = max(0, pl);
pu = max(0, pu);

% Calculate the normalized frequencies
g = (f-f_center)./f_center;
ineg = find(g<0);
ipos = find(g>=0);

% Calcultate transfer
w = zeros(size(g));
w(ipos) = (1+pu(ipos)*g(ipos)).*exp(-pu(ipos).*g(ipos));
w(ineg) = (1-pl(ineg)*g(ineg)).*exp(+pl(ineg).*g(ineg));
