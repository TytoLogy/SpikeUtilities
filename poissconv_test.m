%------------------------------------------------------------------------
%------------------------------------------------------------------------
% poissconv_test.m
%
% demonstrates use of poissconv.m function
%------------------------------------------------------------------------
% 9 Nov 2020 (SJS): moved in edits from
%                    SpikeUtilities/2.0/poissconv_demo.m
%------------------------------------------------------------------------

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
% poisson rise kernel  (milliseconds)
rise = 1;
% poisson fall (milliseconds)
fall = 20;


%------------------------------------------------------------------------
% convolve spike train with Poisson
%------------------------------------------------------------------------
%  (in samples)
[SDF, K, S] = poissconv(S_samples, 'Units', 'samples', 'Fs', Fs);
%  (in ms)
% [SDF, K, S] = poissconv(S_ms, 'Units', 'ms', 'Fs', Fs);
%  (in seconds)
% [SDF, K, S] = poissconv(S_seconds, 'Units', 'seconds', 'Fs', Fs);

figure
subplot(211)
plot( (1000/Fs)*((1:length(K))-1), K, '.-')
title('Poisson Kernel');
xlabel('Time (ms)')

subplot(212)
plot((1000/Fs)*((1:length(SDF))-1), SDF, 'r.')
hold on
plot((1000/Fs)*((1:length(S))-1), S, 'b.') 
hold off
title('Spike Density Function');
xlabel('Time (ms)')
legend({'SDF', 'Spike Events'})


