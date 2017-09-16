function [mSDR, mSIR, mSAR, SDR, SIR, SAR] = perfStatistic_SS(SSperf)
SDR =[]; SIR = []; SAR = [];
for i=1:length(SSperf)
    SDR = [SDR; SSperf(i).SDR];
    SIR = [SIR; SSperf(i).SIR];
    SAR = [SAR; SSperf(i).SAR];
end
mSDR = mean(SDR); mSIR = mean(SIR); mSAR = mean(SAR);
end