%{
				SpikeTools  Information





743e_Test32_Trace1_snippets.mat
743e_Test32_Trace1_snippets.txt
canonical_spike.mat

------------------------------------------------------------------------
poissconv.m
------------------------------------------------------------------------
	[sdf, K, S] = poissconv(spikebins, prise, pdecay)
------------------------------------------------------------------------
	computes spike density function from vector of spike times
	(in samples) with poisson kernel with rise time prise and decay time
	pdecay (samples).
------------------------------------------------------------------------
	Input Arguments:
		spikebins	vector (1XN) of spike times in samples
		prise			poisson rise time (samples)
		pdecay		Poisson decay time in samples

	Output Arguments:
		sdf		spike density function
		K			Poisson kernel
		S			spike events
------------------------------------------------------------------------
	See also: gaussconv
------------------------------------------------------------------------

------------------------------------------------------------------------
spikeconv.m
------------------------------------------------------------------------
	[S, deltaS, spike] = spikeconv(spiketimes, samplerate)
------------------------------------------------------------------------
	Input Arguments:
		spiketimes	vector (1XN) of spike times in seconds
		samplerate	output sampling rate in samples/second

	Output Arguments:
		S			spike train
		deltaS	spike train delta function
		spike		canonical spike structure used for convolution
			Field:
				s			spike data
				t			time vector
				fs			sample rate (samples/second)
				dt			sample interval (seconds)
------------------------------------------------------------------------
	See also: gaussconv, poissconv
------------------------------------------------------------------------


------------------------------------------------------------------------
gaussconv.m
------------------------------------------------------------------------
	[sdf, K, S] = gaussconv(spikebins, glength, gwidth)
------------------------------------------------------------------------

	computes spike density function from vector of spike times
	(in samples) with gaussian length glength and width gwidth (samples).

------------------------------------------------------------------------
	Input Arguments:
		spikebins	vector (1XN) of spike times in samples
		glength		duration (samples) of gaussian kernel
		gwidth		width (std. deviation) of gaussian kernel in samples

	Output Arguments:
		sdf		spike density function
		K			Gaussian kernel
		S			spike events
------------------------------------------------------------------------
	See also: poissconv
------------------------------------------------------------------------



test.wav
100msISI.wav
250msburst.wav
500msburst.wav





poissonkernel.m
poissonkernel_test.m
psp_filter.m

spikewav.m
gaussconv_test.m





%}


