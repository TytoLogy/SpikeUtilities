function [sdf, K, S] = gaussconv(spikebins, glength, gwidth, varargin)
%------------------------------------------------------------------------
% [sdf, K, S] = gaussconv(spikebins, glength, gwidth)
%------------------------------------------------------------------------
% SpikeTools Toolbox
%------------------------------------------------------------------------
% 
% computes spike density function from vector of spike times
% (in samples) with gaussian length glength and width gwidth (samples).
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	spikebins	vector (1XN) of spike times in samples
%	glength		duration (samples) of gaussian kernel
%	gwidth		width (std. deviation) of gaussian kernel in samples
% 
%	Optional:
%  	'MAX_BIN', <max_bin>  Fixed length of bins for output vector 
% 		                        default is time of last spike + 2*gwidth
% 										This is useful if SDFs will be averaged 
% 										or summed
% 		'SCALE_KERNEL'			 If specified, gaussian kernel will be scaled
% 		                      by area under curve (i.e., sum(K)). This can
% 									 help express output as spikes/s. To do this
% 									 multiply scaled kernel SDF by sampling rate
% 									 
%
% Output Arguments:
% 	sdf		spike density function
%	K			Gaussian kernel
%	S			spike events
%------------------------------------------------------------------------
% See also: poissconv
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 30 September, 2010 (SJS)
%
% Revisions:
%	12 October, 2010 (SJS):	cleaned up some things, updated comments
%	29 Aug 2016 (SJS): added max_bin optional arg, updated email
%  16 Nov 2020 (SJS): added SCALE_KERNEL option, modified spec of MAX_BIN
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% check input parameters
%------------------------------------------------------------------------
% if isempty(spikebins)
% 	error('%s: spikebins is empty!', mfilename);
% end

% defaults
max_bin = [];
scale_kernel = false;

if ~isempty(varargin)
	argI = 1;
	while argI <= length(varargin)
		switch upper(varargin{argI})
			case 'MAX_BIN'
				max_bin = varargin{argI + 1};
				argI = argI + 2;
			case 'SCALE_KERNEL'
				scale_kernel = true;
				argI = argI + 1;
			otherwise
				error([mfilename ': unknown option ' varargin{argI}]);
		end
	end
end

%------------------------------------------------------------------------
% get gaussian kernel
%------------------------------------------------------------------------
[K, ~] = gausskernel(glength, gwidth, scale_kernel);
% % center window around 0, which means length of kernel
% % (glength) should be an odd number
% if iseven(glength)
% 	glength = glength+1;
% end
% L2 = ceil(glength/2);
% % "time" (in samples) for gaussian
% x = -L2:L2;
% % gaussian function
% K = exp( -(x./gwidth).^2 );
% if scale_kernel
% 	K = K ./ sum(K);
% end


%------------------------------------------------------------------------
% convert spike samples to spike events
%------------------------------------------------------------------------
% determine length of output vector from input or from spikebins
% if ~isempty(varargin)
% 	max_bin = varargin{1};
% else
% 	max_bin = max(spikebins) + 2*gwidth;
% end
if isempty(max_bin)
	max_bin = max(spikebins) + 2*gwidth;
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
% tmp = conv(S, K);
% sdf = tmp((L2+1):(length(tmp) - L2) );
sdf = conv(S, K, 'SAME');
