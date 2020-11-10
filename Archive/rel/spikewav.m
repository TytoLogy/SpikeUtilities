%------------------------------------------------------------------------
% spikewav
%------------------------------------------------------------------------
% SpikeTools Toolbox
%------------------------------------------------------------------------
% Input Arguments:
%
% Output Arguments:
% 
%------------------------------------------------------------------------
% See also: 
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% Sharad J. Shanbhag
% sshanbhag@neoucom.edu
%------------------------------------------------------------------------
% Created: 29 April, 2011 (SJS)
%
% Revisions:
%------------------------------------------------------------------------


wavfilename = 'burst.wav';
samplerate = 44100;
wav_duration_ms = 1000;

pattern_type = 'SINE_MOD';
frequency = 10;
peak_rate = 100;
base_rate = 10;


pattern_type = 'SINE_PHASELOCK';
frequency = 10;
phase_deg = 90;

pattern_type = 'BURST';
burst_dur_ms = 1000;
burst_delay_ms = 0;
spike_jitter_ms = 0;
burst_rate = 10;


switch pattern_type
	case 'SINE_MOD';
		
		
	case 'SINE_PHASELOCK';
		
	
	case 'BURST';
	
		% first, compute number 
		isi_ms = 1000 * (1/burst_rate);
		% compute tmp isi
		tmp = burst_delay_ms + (0:isi_ms:burst_dur_ms);
		% trim off values that are out of bounds
		valid_index = find( (tmp >= 0) & (tmp <= wav_duration_ms) );
		if ~isempty(valid_index)
			spiketimes = tmp(valid_index)
		else
			warning('%s: no burst spiketimes within bounds of delay and duration', mfilename)
			spiketimes = [];
		end
			
	otherwise;
		error('%s: invalid pattern-type (%s)', mfilename, pattern_type)
end

if ~isempty(spiketimes)
	% call spikeconv to generate spike train
	[s, deltas, Spike] = spikeconv(0.001 * spiketimes, samplerate);
end

% pad end of vector with zeros if needed
ns = length(s);
wavlen = ms2samples(wav_duration_ms, samplerate);

if ns < wavlen
	s = [s zeros(1, wavlen - ns)];
end

% write to wavefile
wavwrite(s, samplerate, 16, wavfilename);

plot(s)
