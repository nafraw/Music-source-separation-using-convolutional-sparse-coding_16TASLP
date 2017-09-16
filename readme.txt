First, You need to download/apply (NOTE: You may need to cite them when you are publishing)
Library:
	BSS Eval (http://bass-db.gforge.inria.fr/bss_eval/) and put into
		\mpe_informed\evaluation\source_separation\bss_eval\
		\score_informed\evaluation\source_separation\bss_eval\
	SPORCO (http://brendt.wohlberg.net/software/SPORCO/) and put into
		\score_informed\algorithm\
		\mpe_informed\algorithm\
	Multi-Pitch Estimator (if you need MPE-based separation)		
		\mpe_informed\MPE\Li Su (https://sites.google.com/site/lisupage/research/cfp_mpe)
		\mpe_informed\MPE\Emmanuel Vincent (http://homepages.loria.fr/evincent/software/multipitch_estimation.m)	
	NOTE: Libraries update from time to time. You might get different result from the paper
Dataset:
	RWC (https://staff.aist.go.jp/m.goto/RWC-MDB/rwc-mdb-i.html)
		for building dictionary from RWC
	Bach10 (http://www.ece.rochester.edu/projects/air/resource.html)
		the used target dataset, may also be used for building dictionary

		
		
Second, if you want to reproduce, here are some steps (You will need to modify some settings in the scripts eventually, at least some paths):

% To make data for building dictionary from RWC
\MPE-informed Source Separator\dataset_preprocess\RWC\script_manual_segment.m
% To build the dictionary for CSC
\mpe_informed\!scripts\build_dictionary\bach10\train_bach10_all.m
% To make the format acceptable by the program later
\score_informed\!scripts\pre_process\preprocess_bach10_all.m
% To run the source separator
\score_informed\!scripts\run_algorithm\run_algorithm\bach10_v3\run_alg_bach10_all.m

% To make data for the dictionary used in the ICASSP version, i.e., using Bach10
read the readme.txt in \dataset_preprocess\Bach10