function [ sig ] = WaveTransform( sig )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

%Wavelet transform
Leadcnt = size( sig, 2 );
for iter = 1:Leadcnt
    [c,l]=wavedec( sig(:,iter),8,'sym8');   % 选取sym8小波对信号做8层分解
    cA8=appcoef(c,l,'sym8',8);
    cD8=detcoef(c,l,8);
    cD7=detcoef(c,l,7);
    cD6=detcoef(c,l,6);
    cD5=detcoef(c,l,5);
    cD4=detcoef(c,l,4);
    cD3=detcoef(c,l,3);
    cD2=detcoef(c,l,2);
    cD1=detcoef(c,l,1);
    % 将cA8，cD1，cD2，cD3过滤（即置零）
    cA8(:,1)=0;
    cD1(:,1)=0;
    cD2(:,1)=0;
    cD3(:,1)=0;
    re_c=[cA8;cD8;cD7;cD6;cD5;cD4;cD3;cD2;cD1];
    sig(:,iter) = waverec(re_c,l,'sym8'); %重构
end

