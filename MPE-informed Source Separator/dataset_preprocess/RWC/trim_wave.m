function new_wav = trim_wave(wav, sampling_rate, start_sec, end_sec)
    start_sample = ceil(start_sec*sampling_rate)+1;
    end_sample   = min(ceil(end_sec*sampling_rate)+1, length(wav));
    
    new_wav = wav(start_sample:end_sample);
end