Run script_main.m for generating dictionary training data
Some notes below

You might also need libraries: a. midi_lib and b. miditoolbox

1, trim length of each chorale if necessary. (Seems trimming is inevitable, as even 10-fold cross validation on full-length audio cannot cover all necessary training data)
	Run script_trim_wave.m to trim the waveform into desired duration.
	Run script_trim_txt.m  to trim the meta-annotation into desired duration (for meta-based score information).
	Run script_trim_midi.m to trim the midi files into desired duration (for score follower based method).

2. calculates the presence of pitch in each chorale for finding validation sets
	Run script_count_pitch_presence_mixed.m for testing set
	Run script_count_pitch_presence.m for training set
	Note: The above two m-files do the same thing except that the implementations are different.
	      The testing and training here only refers to the case of ICASSP version. Actually, one can modify either function for generating testing or training set.
              For example, modify the testing set according to the trim length.

3. find validation subset
	Run find_validation_set_2_fold_vs_5sec for the ICASSP paper setting.
	Run find_validation_set for n_fold setting.

4. generate dictionary training data
	Run script_collect_single_notes_specify_duration.m (MUST MODIFY the valid_set according to the found validation subset!!)
	Run script_collect_single_notes_read_mat_specify_duration.m should be also possible (ICASSP paper used the above one).