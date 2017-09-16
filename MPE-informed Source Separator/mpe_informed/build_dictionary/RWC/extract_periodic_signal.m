%% Extract periodic signal
%  This function is used to extract the periodic signal from a musical
%  instrument with near-perfect periodicity.
%  INPUT:
%    data: 1-dim vector, time series of signal, should consists of several
%    periodicity. An example is the performance of a single note from a
%    trumpet.
%    target_freq: specify if know the target frequency (i.e., f, the
%    frequency of pitch). This is used to alert whether the answer is
%    suspicious and to avoid false period.
%    sampling_rate: sampling rate of data, used it to combine with target 
%    freq to determine period. 
%  OUTPUT:
%    p_sig: the extracted periodic signal.
%    mode_p: mode of found period.
function [p_sig, mode_p] = extract_periodic_signal(data, target_freq, sampling_rate)
%% a parameter for near_point function, [] is default value
err_tor = [];
candidate_num = 10;
if exist('target_freq', 'var') && ~isempty(target_freq)
    target_period = sampling_rate/target_freq;
end
%% detect peak
scale_factor = 10;
trigger = true;
[maxtab, ~] = peakdet(data, max(data)*scale_factor);
mode_p = [];
while isempty(mode_p)
    while size(maxtab,1) < candidate_num
        scale_factor = scale_factor * 0.95;
        [maxtab, ~] = peakdet(data, max(data)*scale_factor);
%         if trigger && scale_factor < 0.5
%             candidate_num = candidate_num * 2;
%             trigger = false
%         end
        if scale_factor < 0.1
            error('There must be some problem in calling the ''extract_period_signal'' function');
        end
    end
    %% for debug, draw result
%     plot(data);
%     hold on;
%     stem(maxtab(:,1), maxtab(:,2), 'r');
    %% use the peak to calculate period
    p = [];
    for i =1:size(maxtab,1)-1
        period = maxtab(i+1,1)-maxtab(i,1);
        if exist('target_period', 'var')
            dif = abs(target_period - period);
            % check whether the difference is large than a ratio of given
            % frequency.
            if dif > 0.2*target_period
                continue;
            end
        end
        p(end+1) = period;
    end
    if length(p) ~= 0
        mode_p = mode(p);
    end
    candidate_num = candidate_num * 2;
end
%% find a suitable period that is equal to mode_p (use the max value)
idx_mode_p = find(p==mode_p);
mode_maxtab = maxtab(idx_mode_p,:);
[~, mi] = max(mode_maxtab(:,2)); % the max value
f_idx = mode_maxtab(mi,1);
s_idx = f_idx-mode_p+1;
if s_idx < 1
    s_idx = s_idx + mode_p;
    f_idx = f_idx + mode_p;
end
%% find the nearest zero-corssing point from s_idx
[shift] = near_zero_cross(data(s_idx:f_idx), err_tor);
p_sig = data(s_idx+shift:f_idx+shift);
%% Check answer
if exist('target_period', 'var')
    if abs(target_period-mode_p) > 0.2*target_period
        warning('the difference between found period and target period is large!');
    end
end
end
%% find the nearest zero-corssing point
% data: the data to be examined.
% err_tor: error tolerance (for finding zero).
function [shift] = near_zero_cross(data, err_tor)
cross = find((abs(diff(sign(data)))== 2) | (abs(diff(sign(data)))== 1));
shift = cross(1)+1;
% abs_data = abs(data);
% if ~exist('err_tor', 'var') || isempty(err_tor)
%    err_tor = max(abs_data)*0.0001; 
% end
% shift = find(abs_data <= err_tor, 1, 'first') - 1;

end