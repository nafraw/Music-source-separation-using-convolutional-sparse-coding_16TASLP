%% reconstruction
%  INPUT:
%    D: an m by n matrix, dictionary.
%    maskD: a cell with p-dim. Each cell is a vector for index of
%    extracting sub-dictionary for each partition.
%    S_input_path: a file that has an t by n by p tensor, coefficient map.
%    norm_ratio, a p-dimensional vector. The ratio used in normalizing.
%    original time signal.
%    partition_set: this is a 2 by k by p matrix such that the source will be
%    separated into k channels for each partition.
%  OUTPUT:
%    R: a t*k matrix.
function [R] = reconstruct_window_wise_v3(output_path, sampling_rate, D, maskD, ...
                                       S_input_path, norm_ratio, partition_set, ...
                                       length_pad_audio, length_audio, mix_audio, param)
    %% read S
    stru = importdata(S_input_path);
    if isempty(maskD)
        maskD = stru.maskD;
    end
    if isempty(partition_set)
        partition_set = stru.partition_set;
    end
    l = size(D, 1);
    k = size(partition_set, 2);
    p = size(partition_set, 3);
    R = zeros(length_pad_audio, k);    
    d = zeros(length_pad_audio, 1); % denominator for averaging    
    m = size(stru.S{1},1) - 2*l;
    s = 1;
    zp = 0;
    
    mix_audio = [mix_audio; zeros(length_pad_audio-length_audio,1)];
    
    for pid = 1:p
        %% reconstruct from dictionary and coefficient
        subD = D(:, maskD{pid});        
        if ~isfield(param, 'fft')
            [rec] = reconstruct_signal_window(subD, stru.S{pid}, zp, ...
                                 norm_ratio(pid), partition_set(:,:,pid));
        else
            if param.fft == 0
                [rec] = reconstruct_signal_window(subD, stru.S{pid}, zp, ...
                    norm_ratio(pid), partition_set(:,:,pid));
            else
                [rec] = reconstruct_signal_window_fft(subD, stru.S{pid}, zp, ...
                    norm_ratio(pid), partition_set(:,:,pid));
            end
        end
        rec = rec(l+1:end-l,:);
        
        [rec] = wiener_on_time(rec, mix_audio(1+(s-1)*param.hop:(s-1)*param.hop+m), param);
        
        R(1+(s-1)*param.hop:(s-1)*param.hop+m, :) = R(1+(s-1)*param.hop:(s-1)*param.hop+m, :) + rec;
        d(1+(s-1)*param.hop:(s-1)*param.hop+m, 1) = d(1+(s-1)*param.hop:(s-1)*param.hop+m, 1) + 1;
        s = s + 1;
        clear rec;
    end    
    R = R./repmat(d, [1 k]);
    R = R(1:length_audio,:);
    if isfield(param, 'post_weiner')
        if param.post_weiner
            [stft_mixture, ~, ~] = cal_stft(mix_audio, param.stft);
            stft_mixture = squeeze(stft_mixture);
            for kid = 1:k
                [tmp, ~, ~] = cal_stft(R(:,kid), param.stft);
                stft_src(:,:,kid) = squeeze(tmp);
            end
            R = weiner_reconstruct_stft(stft_mixture, stft_src, length_audio, param.stft.hop);
        end
    end
    %% save as a file or files    
    [folder, file, ext] = fileparts(output_path);
    if ~exist(folder, 'dir')
        mkdir(folder);
    end
    wavwrite(sum(R,2), sampling_rate, output_path);    
    for kid = 1:k
        if k == 1
            wavwrite(R, sampling_rate, output_path);
        else
            output_path = [folder, '/', file, '_channel_', num2str(kid), ext];
            wavwrite(R(:,kid), sampling_rate, output_path);
        end
    end
end

function [rec] = wiener_on_time(rec, mix, param)
%% method 1
% k = size(rec, 2);
% dn = sum(abs(rec), 2);
% for i =1:k
%     n = abs(rec(:,i));
%     rec(:,i) = n./dn.*rec(:,i);
% end
%% method 2
% param.wiener.wlen = length(mix);
% param.wiener.hop = length(mix);
% k = size(rec, 2);
% [stft_mixture, ~, ~] = cal_stft(mix, param.wiener);
% stft_mixture = stft_mixture';
% for i=1:k
% stft_rec(:,i) = squeeze(cal_stft(rec(:,i), param.wiener));
% end
% dn = sum(abs(stft_rec), 2);
% for i=1:k
%     n = abs(stft_rec(:,i));
% %     stft_rec(:,i) = abs(n./dn.*stft_mixture).*exp(1i*angle(stft_rec(:,i)));    
%     stft_rec(:,i) = n./dn.*stft_mixture;
%     rec(:,i) = ifft(stft_rec(:,i), 'symmetric');
% end
%% method 2-2
nsample = length(mix);
param.wiener.wlen = length(mix);
param.wiener.hop = param.stft.hop;
stft_mixture = cal_stft(mix, param.stft);
stft_mixture = squeeze(stft_mixture);
k = size(rec, 2);
for kid = 1:k
    [tmp, ~, ~] = cal_stft(rec(:,kid), param.stft);
    stft_src(:,:,kid) = squeeze(tmp);
end
rec = weiner_reconstruct_stft(stft_mixture, stft_src, nsample, param.wiener.hop);
end