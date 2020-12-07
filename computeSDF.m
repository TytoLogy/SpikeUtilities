function varargout = computeSDF(spiketimes, opt)
%------------------------------------------------------------------------
% [SDF, SDFmean] = computeSDF(spiketimes, opt)
%------------------------------------------------------------------------
% TytoLogy:Toolbox:SpikeUtilities:computeSDF
%------------------------------------------------------------------------
%
%------------------------------------------------------------------------
% Input Args:
% 	spiketimes		{ntrials, 1} cell array with each element being a vector
% 	               of spike times in milliseconds
%    opt            options struct
% 		opt.Fs       sampling rate for spike density function 
%                    (samples/s)
% 		opt.maxdur   max length of sdf (ms)
% 		opt.kwidth   width of gaussian (ms)
% 							essentially the "standard deviation" 
% 		opt.klength  length of gaussian (ms)
% 							this should be 5-7 times kwidth
%     opt.FR       if true, convert SDF values to firing rate (spikes/s)
% 
% Output Args
%	SDF	    spike density function cell array {ntrials, 1} in spikes/s
%  SDFmean   mean spike density function [1, opt.maxdur * 0.001/opt.Fs]
%------------------------------------------------------------------------

%------------------------------------------------------------------------
% values used with sdf
%------------------------------------------------------------------------
% convert settings to bins
% gaussian kernel of length klength_bins and width
% kwidth_bins. maxbins sets maximum length of the sdf vector
klength_bins =  ms2bin(opt.klength, opt.Fs);
kwidth_bins = ms2bin(opt.kwidth, opt.Fs);
maxbins =  ms2bin(opt.maxdur, opt.Fs);
if opt.FR
	% factor to convert to FR
	[~, Kg_sum] = gausskernel(klength_bins, kwidth_bins);
	FRconst = opt.Fs / Kg_sum;
else
	FRconst = 1;
end
%------------------------------------------------------------------------
% get number of reps (aka trials)
%------------------------------------------------------------------------
reps = length(spiketimes);
if reps == 0
	error('%s: spiketimes is empty', mfilename);
end

%------------------------------------------------------------------------
% build sdfs for each sweep
%------------------------------------------------------------------------
% allocate storage
SDFs = cell(reps, 1);
% loop through reps
for n = 1:reps
	% compute sdf for this trial - convert spiketimes to bin (offset by 1 to
	% account for index in matlab starting at 1) and use gaussconv to
	% convolve spikes 
	SDFs{n} = ...
		FRconst*gaussconv( ms2bin(spiketimes{n}, opt.Fs) + 1, ...
					          klength_bins, kwidth_bins, ...
						       'MAX_BIN', maxbins);
end

varargout{1} = SDFs;

% compute mean fr if desired
if nargout > 1
	varargout{2} = mean(cell2mat(SDFs));
end
