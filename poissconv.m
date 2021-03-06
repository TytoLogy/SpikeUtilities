function [sdf, K, S] = poissconv(spiketimes, varargin)
%------------------------------------------------------------------------
% [sdf, K, S] = poissconv(spiketimes, <options>)
%------------------------------------------------------------------------
% SpikeUtilities Toolbox
%------------------------------------------------------------------------
% 
% computes spike density function from vector of spike times (spiketimes)
% (in milliseconds) with poisson kernel with rise time Trise 
% and decay time Tdecay.  Default units are milliseconds.
% 
% Based upon method in: 
% Thompson, K. G., Hanes, D. P., Bichot, N. P., &
% Schall, J. D. (1996). Perceptual and motor processing stages identified
% in the activity of macaque frontal eye field neurons during visual
% search. Journal of Neurophysiology, 76(6), 4040?4055.
% 
%------------------------------------------------------------------------
% Input Arguments:
% 	spiketimes		vector (1XN) of spike times
% 						default behavior is to have spike times in 
% 						milliseconds.  These units should be consistent
% 						across all input parameters (e.g., Trise, Tdecay)
% 						Alternate units may be specified using the "Units"
% 						option.
% 	
% 	Optional:
%		'Trise', <value>						Poisson rise time constant
% 														default: 1 ms
%		'Tdecay'	<value>						Poisson decay time constant
%														default: 20 ms
%		'Units', <'ms'|'s'|'samples'>		Units for spiketimes, Trise, Tdecay, 
%													Maxdur
%														default: ms
%		'Fs'										Sample rate for output SDF
%														default = 1000 samples/second
% 		'Maxdur'		max duration to use for sdf vectors.
% 						note that if this is not provided, empty
% 						spikebins vector will cause error to be thrown.
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
%	11 Dec 2013 (SJS)
%	 -	revised contact email address
%	 -	reworked spikebins empty handling
%	10 Feb 2015 (SJS)
% 	 - reworked input arguments to use ms units by default
%	 - updated documentation
%	11 Nov 2020 (SJS): cleaning up code  
%------------------------------------------------------------------------

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% set defaults
%------------------------------------------------------------------------
%------------------------------------------------------------------------
Maxdur = [];
Trise = 1;
Tdecay = 20;
Fs = 1000;
decay_factor = 5;
Units = 'ms';

userTrise = 0;
userTdecay = 0;
userFs = 0; %#ok<NASGU>

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% check input parameters
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if nargin == 0
	error('%s: spikes!\n', mfilename);
end
% check for other parameters
nvararg = length(varargin);
if nvararg
	aindex = 1;
	while aindex <= nvararg
		switch(upper(varargin{aindex}))
			% Specify Poisson rise time constant
			case 'TRISE'
				Trise = varargin{aindex + 1};
				userTrise = 1;
				aindex = aindex + 2;
			% Specify Poisson decay time
			case 'TDECAY'
				Tdecay = varargin{aindex + 1};
				userTdecay = 1;
				aindex = aindex + 2;
			% Specify output data sampling rate
			case 'FS'
				Fs = varargin{aindex + 1};
				userFs = 1; %#ok<NASGU>
				aindex = aindex + 2;
			% Units
			case 'UNITS'
				switch upper(varargin{aindex + 1})
					case {'MS', 'MSEC', 'MILLISECOND', 'MILLISECONDS'}
						Units = 'ms';
					case {'SAMPLE', 'SAMPLES'}
						Units = 'samples';
					case {'S', 'SEC', 'SECOND', 'SECONDS'}
						Units = 'seconds';
					otherwise
						error('%s: units %s not supported', mfilename, ...
															varargin{aindex + 1});
				end
				aindex = aindex + 2;
			% max duration
			case {'MAXDUR', 'MAX_DUR', 'MAX_T'}
				Maxdur = varargin{aindex + 1};
				aindex = aindex + 2;
			otherwise
				error('%s: Unknown option %s', mfilename, varargin{aindex});
		end		% END SWITCH
	end		% END WHILE aindex
end		% END IF nvararg


%------------------------------------------------------------------------
%------------------------------------------------------------------------
% Set up Poisson kernel
%------------------------------------------------------------------------
%------------------------------------------------------------------------
if strcmpi(Units, 'ms')
	%----------------------------------------------------------------
	% build kernel
	%----------------------------------------------------------------
	% for msec, no conversion of units is necessary
	Klength = decay_factor * Tdecay;
	% time vector for kernel (in samples)
	tvec = 0:(1000/Fs):Klength;
	% kernel is product of 2 exponentials
	K = (1-exp(-tvec/Trise)) .* exp(-tvec/Tdecay);
	% normalize so peak is 1
	K = K./max(K);
	%----------------------------------------------------------------
	% convert spikes to sample times
	%----------------------------------------------------------------
	% since spiketimes are in units of milliseconds, use ms2samples
% 	spikebins = ms2samples(spiketimes, Fs);
	% adding 1 to account for matlab indexing
	spikebins = ms2samples(spiketimes, Fs) + 1;
	% convert Maxdur to maxsamples
	if isempty(Maxdur)
		maxsamples = max(spikebins) + ms2samples(Klength, Fs);
	else
		maxsamples = ms2samples(Maxdur, Fs);
	end
	
elseif strcmpi(Units, 'samples')
	%----------------------------------------------------------------
	% build kernel
	%----------------------------------------------------------------
	% convert Tdecay, Trise to samples (if provided by user)
	if ~userTrise
		Trise = ms2samples(Trise, Fs);
	end
	if ~userTdecay
		Tdecay = ms2samples(Tdecay, Fs);
	end
	% total length for kernel
	Klength = decay_factor * Tdecay;
	% time vector for kernel (in samples)
	tvec = 0:Klength;
	% kernel is product of 2 exponentials
	K = (1-exp(-tvec/Trise)) .* exp(-tvec/Tdecay);
	% normalize so peak is 1
	K = K./max(K);
	%----------------------------------------------------------------
	% spikes are already in samples...
	%----------------------------------------------------------------
	spikebins = spiketimes;
	% convert Maxdur to maxsamples
	if isempty(Maxdur)
		maxsamples = max(spikebins) + Klength;
	else
		maxsamples = Maxdur;
	end
	
elseif strcmpi(Units, 'seconds')
	%----------------------------------------------------------------
	% build kernel
	%----------------------------------------------------------------
	% convert Tdecay, Trise to seconds (if not provided by user)
	if ~userTrise
		Trise = 0.001 * Trise;
	end
	if ~userTdecay
		Tdecay = 0.001 * Tdecay;
	end
	% total length for kernel
	Klength = decay_factor * Tdecay;
	% time vector for kernel (in samples)
	tvec = 0:(1/Fs):Klength;
	% kernel is product of 2 exponentials
	K = (1-exp(-tvec/Trise)) .* exp(-tvec/Tdecay);
	% normalize so peak is 1
	K = K./max(K);
	%----------------------------------------------------------------
	% convert spikes to sample times
	%----------------------------------------------------------------
	% convert spikes to ms, then use ms2samples
% 	spikebins = ms2samples(1000.*spiketimes, Fs);
	spikebins = ms2samples(1000.*spiketimes, Fs) + 1;
	% convert Maxdur to maxsamples
	if isempty(Maxdur)
		maxsamples = max(spikebins) + ms2samples(1000*Klength, Fs);
	else
		maxsamples = ms2samples(1000*Maxdur, Fs);
	end
end

%------------------------------------------------------------------------
%------------------------------------------------------------------------
% convert spike samples to spike events in time vector
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% allocate S (spike) event vector
S = zeros(1, maxsamples);
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
%------------------------------------------------------------------------
% convolve spike train with Gaussian, return only valid part of 
% convolution output (length = length(S))
%------------------------------------------------------------------------
%------------------------------------------------------------------------
% % pad S with zeros to eliminate odd things at start and end
% padlen = length(K);
% Spad = [zeros(1, padlen) force_row(S) zeros(1, padlen)];
% sdftmp = conv(Spad, K);
% % keep original bits
% sdf = sdftmp( (padlen:(padlen+length(S)))+1 );
% %sdf = tmp((L2+1):(length(tmp) - L2) );
% if ~isempty(maxsamples)
% 	sdf = sdf(1:maxsamples);
% end

%------------------------------------------------------------------------
% convolve spike train with Gaussian, return only valid part of 
% convolution output (length = length(S))
%------------------------------------------------------------------------
% L2 = length(K);
% tmp = conv(S, K);
% sdf = tmp((L2+1):(length(tmp) - L2) );
% if ~isempty(maxsamples)
% 	sdf = sdf(1:maxsamples);
% end
% sdf = conv(S, K, 'SAME');
% if ~isempty(maxsamples)
% 	sdf = sdf(1:maxsamples);
% end

% find peak index
[~, pkI] = max(K);
% find pts to add to beginning to shift to center
nshift = length(K) - (pkI + 2);
if even(length(nshift) + length(K))
	nshift = nshift - 1;
end
% add to K
K = [zeros(1, nshift) K];
% perform convolution, return same length vector as S
sdf = conv(S, K, 'SAME');
% truncate sdf if length is greater than maxsamples
if ~isempty(maxsamples)
	if length(sdf) > maxsamples
		sdf = sdf(1:maxsamples);
	end
end