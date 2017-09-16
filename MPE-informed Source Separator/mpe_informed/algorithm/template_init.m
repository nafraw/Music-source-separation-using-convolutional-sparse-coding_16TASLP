function [W] = template_init(time_constr, pitch, f, t)
%  OUTPUT:
%    W: a m-by-n matrix
%  INPUT:
%    time_constr: a n-by-2 matrix, which represents the onset and offset of
%    the template in terms of index, but may exceeds the boundary.
%    pitch: a n-dim vector, which represents the target pitch.
%    f: a m-dim vector, which represent the frequency of each bin.

all_pitch = pitch;
% all_pitch = [];
% for i = 1:length(pitch)
%     all_pitch = [all_pitch; pitch{i}];
% end
m = length(f);
n = length(all_pitch);
F = max(f);
%% initialize H
% H = zeros(n, t);
% tid = 0; % template index
% for i = 1:size(time_constr,1) % for each time constraint
%     ctid = tid + time_constr(i,3);
%     act_period = time_constr(i,1): time_constr(i,2); % activation period
%     act_period(act_period > t) = []; % check for boundary case
% %     H(ctid, act_period) = 1;
%     H(ctid, act_period) = rand(1, length(act_period));
% end
% tid = tid + length(pitch{inst});


%% initialize W
W = zeros(m, n);
%% initialize each column of W with each pitch
for i = 1:n
    p = all_pitch(i); % target pitch    
    %% calculate the frequency range
    lowF = midi_to_pitch(p-1);
    highF = midi_to_pitch(p+1);
    nHar = 1; % order of harmonic
    while true
        %% calculate the frequency range
        lb = nHar * lowF;  % lower bound
        ub = nHar * highF; % upper bound
        % break condition
        if lb > F
            break;
        end
        %% calculate the corresponding row indices in A
        sidx = find(f <= lb, 1, 'last');
        eidx = find(f >= ub, 1, 'first');
        %% initialize the column
        W(sidx:eidx, i) = 1/(nHar^2);
        %% next step
        nHar = nHar + 1;        
    end    
end

end

function freq = midi_to_pitch(pitch)
    freq = 440 * 2^((pitch-69)/12);
end
