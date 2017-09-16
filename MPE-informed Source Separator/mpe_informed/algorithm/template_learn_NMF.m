function [W, H, optinf] = template_learn_NMF(p_stft, used_pitch, time_constr, freq, param)
% OUTPUT:
%
% INPUT:

%% Setting time-frequency constraint 
% (initialize the frequency template matrix, W)
% (initialize the activation matrix, H)
t = size(p_stft, 2);
[W, H] = template_init_vlearn(time_constr, used_pitch, freq, t, param.initH, param.initW, param.nPitch);
%% multiplicative NMF
[W, H, optinf] = nnmf(p_stft, W, H, size(W, 2), param.iteration, param.error_criterion);
end
   