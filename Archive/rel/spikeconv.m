function [S, deltaS, spike] = spikeconv(spiketimes, samplerate, varargin)
%------------------------------------------------------------------------
% [S, deltaS, spike] = spikeconv(spiketimes, samplerate, spiketime_format)
%------------------------------------------------------------------------
% SpikeTools Toolbox
%------------------------------------------------------------------------
% Input Arguments:
% 	spiketimes	vector (1XN) of spike times in seconds (default format)
%					or spike events (see spiketimes_fmt option, below)
%	samplerate	output sampling rate in samples/second
%	
%	Optional Input:
%	 spiketimes_fmt	indicates if spiketimes vector is in 
%							'time'	spiketimes in seconds (default)
%							'event'		spike events (vector with spike
% 											events indicated by 1 at spike event sample 
%											location)
% 
% Output Arguments:
%	S			spike train
% 	deltaS	spike train "delta" function (0 at samples with no spikes, 1 at
%				samples with spikes)
% 	spike		canonical spike structure used for convolution
% 		Field:
% 			s			spike data
% 			t			time vector
% 			fs			sample rate (samples/second)
% 			dt			sample interval (seconds)
%------------------------------------------------------------------------
% See also: gaussconv, poissconv
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 28 April, 2011 (SJS)
%
% Revisions:
%	29 Apr 2011 (SJS)
%	 -	completed script 
% 	 -	changed from script to function
%	10 July 2018 (SJS)
%	 - cleaned up
%	 - added 'time' or 'event' option to deal with spiketimes vector
%	 given as 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% check input parameters
%------------------------------------------------------------------------
if nargin < 2
	error('%s: incorrect input args', mfilename);
end
if ~isempty(varargin)
	if strcmpi(varargin{1}, 'time')
		spiketimes_fmt = 0;
	elseif strcmpi(varargin{1}, 'event')
		spiketimes_fmt = 1;
	else
		error('Invalid spiketimes_fmt %s', varargin{1});
	end
else
	spiketimes_fmt = 0;
end

%------------------------------------------------------------------------
% load canonical spike kernel struct
% 	spike			structure
% 		Field:
% 			s			spike data
% 			t			time vector
% 			fs			sample rate (samples/second)
% 			dt			sample interval (seconds)
%------------------------------------------------------------------------
if ~exist('canonical_spike.mat', 'file')
	error('%s: canonical_spike.mat not found!', mfilename)
else
	load('canonical_spike.mat', 'spike');
end

%------------------------------------------------------------------------
% resample spike.s if necessary (if samplerate ~= spike.fs)
%------------------------------------------------------------------------
if samplerate ~= spike.fs %#ok<NODEF>
	spike.s = resample(spike.s, samplerate, spike.fs);
	spike.fs = samplerate;
	spike.dt = 1/samplerate;
	spike.t = (0:(length(spike.s)-1)) * spike.dt;
end
	
%------------------------------------------------------------------------
% convert spike samples to spike events
%------------------------------------------------------------------------
if isempty(spiketimes)
	warning('%s: spikebins is empty!', mfilename);
	S = 0;
	return
end

%------------------------------------------------------------------------
% for spiketimes in 'time' format:
% compute bins in which spikes occurred - add offset of 1 to account for
% time == 0 mapping to spikebin 1
%------------------------------------------------------------------------
if spiketimes_fmt == 0
	spikebins = round((samplerate*spiketimes) + 1);
	% if spikes exist at first sample, zero pad
	lpad = 0;
	if spikebins(1) == 1
		lpad = length(spike.s)*spikebins(1);
	end
	% need to pad end of data
	rpad = length(spike.s);
	% pre-allocate delta function vector
	deltaS = zeros(1, spikebins(end) + lpad + rpad);
	% set samples that contain spikes to 1
	deltaS(spikebins) = ones(1, length(spikebins));
else
	deltaS = spiketimes;
	if spiketimes(1) == 1
		lpad = length(spike.s);
		deltaS = [lpad deltaS];
	else
		lpad = 0;
	end
end

%------------------------------------------------------------------------
% convolve spike train with canonical spike shape, return only valid part of 
% convolution output (length = length(S))
%------------------------------------------------------------------------
S = conv(deltaS, spike.s, 'same');

%------------------------------------------------------------------------
% trim lpad from S
%------------------------------------------------------------------------
if lpad
	S = S( (lpad+1):end );
	deltaS = deltaS( (lpad+1):end );
end

