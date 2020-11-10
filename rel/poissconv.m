function [sdf, K, S] = poissconv(spikebins, prise, pdecay, varargin)
%------------------------------------------------------------------------
% [sdf, K, S] = poissconv(spikebins, prise, pdecay)
%------------------------------------------------------------------------
% SpikeTools Toolbox
%------------------------------------------------------------------------
% 
% computes spike density function from vector of spike times
% (in samples) with poisson kernel with rise time prise and decay time
% pdecay (samples).
% 
% common values for prise and pdecay (in milliseconds - be sure
% to convert to samples!!!!) are prise = 1 msec, pdecay = 20 msec
%
% See Thompson et al. (1996) J Neurophys for details
%------------------------------------------------------------------------
% Input Arguments:
% 	spikebins	vector (1XN) of spike times in samples
%	prise			poisson rise time (samples)
%	pdecay		Poisson decay time in samples
% 
%	Optional:
% 		max_bin		Fixed length of bins for output vector (default is 
% 						time of last spike + pdecay)
%						This is useful if SDFs will be averaged or summed
% 
% Output Arguments:
% 	sdf		spike density function
%	K			Poisson kernel
%	S			spike events
%------------------------------------------------------------------------
% See also: gaussconv
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 27 October, 2010 (SJS)
%
% Revisions:
%	29 Aug 2016 (SJS): added max_bin optional arg, updated email
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% check input parameters
%------------------------------------------------------------------------
if isempty(spikebins)
	error('%s: spikebins is empty!', mfilename);
end

%------------------------------------------------------------------------
% Set up poisson kernel
%------------------------------------------------------------------------
% 4* decay time is usually safe for kernel
Klength = 5 * pdecay;
% time vector for kernel
n = 0:Klength;
% kernel is product of 2 exponentials
K = (1-exp(-n/prise)) .* exp(-n/pdecay);
% normalize so peak is 1
K = normalize(K);

%------------------------------------------------------------------------
% convert spike samples to spike events
%------------------------------------------------------------------------
% determine length of output vector from input or from spikebins
if ~isempty(varargin)
	max_bin = varargin{1};
else
	max_bin = max(spikebins) + pdecay;
end

% create S vector
S = zeros(1, max_bin);

nspikes = length(spikebins);
if nspikes
	% if nspikes ~= 0, set samples that contain spikes to 1
	S(spikebins) = ones(1, length(spikebins));
else
	% otherwise, return vector of zeros
	sdf = S;
	return
end

%------------------------------------------------------------------------
% convolve spike train with Gaussian, return only valid part of 
% convolution output (length = length(S))
%------------------------------------------------------------------------
tmp = conv(S, K);
%sdf = tmp((L2+1):(length(tmp) - L2) );
sdf = tmp;



