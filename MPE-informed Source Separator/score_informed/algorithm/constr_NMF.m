function [W, H, optinf] = constr_NMF(p_stft, W0, used_pitch, time_constr, freq, param)
% OUTPUT:
%
% INPUT:

%% Setting time-frequency constraint 
% (initialize the frequency template matrix, W)
% (initialize the activation matrix, H)
t = size(p_stft, 2);
[W, H] = template_init_v2(time_constr, used_pitch, freq, t, param.initH, param.initW, param.nPitch);
if param.initW == 0
    W = W0;
end
%% multiplicative NMF
if size(W, 2) == 0
    W = [];
    H = [];
    optinf = [];
else
    [W, H, optinf] = nnmf_v2(p_stft, W, H, size(W, 2), param.iteration, param.error_criterion, param.fixW);
end
end
   