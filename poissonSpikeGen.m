function [spikeMat, tVec] = poissonSpikeGen(fr, tMax, Fs, nTrials)
%
% fr		firing rate (spikes/second)
% tMax	max time for spike train simulation (seconds)
% Fs		sampling rate for spike train (Hz)
% nTrials # of trials to simulate
%
% spikeMat	[nTrials, tMax*Fs] matrix of spiketimes (seconds)
% Code adapted from 
% https://praneethnamburi.com/2015/02/05/simulating-neural-spike-trains/
dt = 1/Fs; % s
nBins = floor(tMax/dt);
spikeMat = rand(nTrials, nBins) < fr*dt;
tVec = 0:dt:tMax-dt;