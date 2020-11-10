%------------------------------------------------------------------------
% test spike time data
%------------------------------------------------------------------------
% sampling rate (used for calculating spike density function)
Fs = 40000;

S_ms = [	25    75   145   225   240   250   255   ...
			270   275   350   400   425   450  455   500];
% spike times in samples
S_samples = Fs * 0.001 * S_ms;

%------------------------------------------------------------------------
% gaussian settings
%------------------------------------------------------------------------
% Gaussian kernel duration (milliseconds)
Length = 50;
% Gaussian sigma (width)
Width = 10;

% convert length and width to samples
L = ms2bin(Length, Fs);
Sigma = ms2bin(Width, Fs);

%------------------------------------------------------------------------
% convolve spike train with Gaussian
%------------------------------------------------------------------------
[SDF, K, S] = gaussconv(S_samples, L, Sigma);

if iseven(L)
	L = L+1;
end
L2 = ceil(L/2);
% "time" (in samples) for gaussian
x = -L2:L2;


figure(1)
subplot(211)
plot(x, K, '.-')

subplot(212)
plot(SDF, '.-')


figure(2)
plot(SDF, 'r.')
hold on
plot(S, 'b.') 
hold off
legend({'SDF', 'spike times'})


