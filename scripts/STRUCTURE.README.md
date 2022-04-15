
SB 6/10/2020: I have made two changes to the "params"
	This is a very old-school s/w and it doesn't do any CLI overrides, instead rigid "params" files are used
	Change 1: I reduced burn-in and MCMC periods to half (5000 and 10000 iterations); this can be further tuned
	Change 2: #define USEPOPINFO  1 // (B) Use prior population information !!
	Second change affects a lot of the programs behavior: 
	clusters are honored and initialized stably. (Then as needed members migrate between clusters but initial setting is crucial.)
	Output is different. therefore R program errors out and breaks.
	Added ./reformat_f.pl script (easy re-formatter)

