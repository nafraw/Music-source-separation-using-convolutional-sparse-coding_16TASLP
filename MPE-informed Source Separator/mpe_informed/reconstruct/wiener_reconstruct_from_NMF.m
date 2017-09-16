function rec = wiener_reconstruct_from_NMF(W, H, inst_id, nsample, stft, norm_ratio, hop)
k = max(inst_id);
f = size(W, 1);
t = size(H, 2);
nfbin = size(stft, 1);
rec = zeros(nsample, k);
%% Calculate wiener gain
% denominator
dn = W*H;
dn(dn==0) = inf;
% gain = nominator/denominator
for inst = 1:k
    %% reconstruct spectrogram of each instrument
    id = find(inst_id == inst);
    if isempty(id)
        gain = zeros(f,t);
    else
%         gain = ((W(:,id)*H(id,:)).^2)./(dn.^2);
        gain = (W(:,id)*H(id,:))./dn;
    end    
    %% replicate negative frequency part
    if mod(nfbin, 2) % odd point
        gain = [gain; flipud(gain(2:end,:))];
    else % even point
        gain = [gain; flipud(gain(2:end-1,:))];
    end    
    %% Wiener filtering
%     rec_spec = stft.*sqrt(gain);
    rec_spec = stft.*gain;
    %% reconstruct time-domain signal for each instrument
    r = reconstruct_fft(rec_spec, hop);
    r = norm_ratio .* r;
    rec(:, inst) = r(1:nsample);
end

end

function r = reconstruct_fft(rec_fft, hop)
[m, n] = size(rec_fft); % how many frequency bins and frames
t = hop * (n-1) + m;
z = zeros(t,1);
d = zeros(t,1);
% for each frame
for t = 1:n
    % reconstuct for each frame and put into appropriate locations
    z(1+(t-1)*hop:(t-1)*hop+m,1) = z(1+(t-1)*hop:(t-1)*hop+m,1) +...
            ifft(rec_fft(:,t), 'symmetric');
    d(1+(t-1)*hop:(t-1)*hop+m) = d(1+(t-1)*hop:(t-1)*hop+m) + 1;
end
r = z./d;
end