function [K, varargout] = gausskernel(glength, gwidth, varargin)
%------------------------------------------------------------------------
% [K, Karea] = gausskernel(glength, gwidth, <scale kernel>)
%------------------------------------------------------------------------
% SpikeTools Toolbox
%------------------------------------------------------------------------
% 
% computes Gaussian kernel for use with spike density function
% with length glength and width gwidth (in samples).
%
% if optional input scale_kernel is TRUE, area under the kernel will be
% scaled to a value of 1
% 
%------------------------------------------------------------------------
% Input Arguments:
%	glength		duration (samples) of gaussian kernel
%	gwidth		width (std. deviation) of gaussian kernel in samples
% 
%	Optional:
% 		SCALE_KERNEL			 If true, gaussian kernel will be scaled
% 		                      by area under curve (i.e., sum(K)). This can
% 									 help express output as spikes/s. To do this
% 									 multiply scaled kernel SDF by sampling rate
% 									 Default: false
%
% Output Arguments:
%	K			Gaussian kernel
%	Kmag		cumulative sum of kernel (area under curve)
%------------------------------------------------------------------------
% See also: gaussconv, poissconv
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neomed.edu
%------------------------------------------------------------------------
% Created: 1 December 2020 (SJS)
%            pulled out of gaussconv.m
%
% Revisions:
%------------------------------------------------------------------------

% defaults
scaleFlag = false;

if ~isempty(varargin)
	if varargin{1} == true
		scaleFlag = true;
	elseif varargin{1} == false
		scaleFlag = false;
	else
		error('%s: invalid scale_kernel option %s', mfilename, varargin{1});
	end
end

%------------------------------------------------------------------------
% Set up gaussian kernel
%------------------------------------------------------------------------
% center window around 0, which means length of kernel
% (glength) should be an odd number
if iseven(glength)
	glength = glength+1;
end
L2 = ceil(glength/2);

% "time" (in samples) for gaussian
x = -L2:L2;
% gaussian function
K = exp( -(x./gwidth).^2 );

% compute sum (area)
Ksum = sum(K);

% scale kernel if flag is true
if scaleFlag
	K = K ./ Ksum;
end

varargout{1} = Ksum;


