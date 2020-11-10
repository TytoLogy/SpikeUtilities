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
% Poisson settings
%------------------------------------------------------------------------
% rise time (milliseconds)
prise = 1;
% fall time (width)
pdecay = 20;

% convert length and width to samples
prise_samples = ms2bin(prise, Fs);
pdecay_samples = ms2bin(pdecay, Fs);

%------------------------------------------------------------------------
% convolve spike train with Gaussian
%------------------------------------------------------------------------
[SDF, K, S] = poissconv(S_samples, prise_samples, pdecay_samples);

if iseven(L)
	L = L+1;
end
L2 = ceil(L/2);
% "time" (in samples) for gaussian
x = -L2:L2;


figure(1)
subplot(211)
plot(K, '.-')

subplot(212)
plot(SDF, '.-')


figure(2)
plot(SDF, 'r.')
hold on
plot(S, 'b.') 
hold off
legend({'poisson SDF', 'spike times'})


