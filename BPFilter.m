function [ Filtered ] = BPFilter( Signal )
%Here is sample function just modified by ECGWavesDect.m from ECGWaveDect.m
%Filtered for 8 ~ 20 Hz
%Author:    Pan Jiabin
%Orignal data:  2015/12/03

LPara1 = [1 0 0 0 0 0 -2 0 0 0 0 0 1];
LPara2 = [1 -2 1];
HPara1 = [-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1];
HPara2 = [1 -1];


%LPF
L = filter( LPara1, LPara2, Signal ) / 24;

%HPF
H = filter( HPara1, HPara2, L )/24;

%Filter Delay
Filtered = H((22:end),:);


end

