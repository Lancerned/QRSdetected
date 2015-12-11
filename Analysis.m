clear all;close all;clc;
data_dir=[pwd filesep];
addpath(pwd)

recordName = [ data_dir '104' ];
[ Signal, Fs, Siginfo, Atrinfo ]=rddat(recordName);
fprintf( 'Rddat finished.\n');
Signal = Signal( :,1 );
Signal = BPFilter( Signal );
Signal = WaveTransform( Signal );

plot(Signal);
hold on;

slope = Signal( 2:end ) - Signal( 1:end-1 );
plot( slope,'r' );
hold on;

% abs_slope = abs(slope);
abs_slope = slope.*slope;
plot( abs_slope,'k' );
hold on;

% % Slide Swallow 
% idx = ceil( 0.05 * Fs );
% sum_left = sum( abs_slope(1:idx) );
% sum_right = sum( abs_slope(idx+2:idx*2 + 1) );
% swallow = zeros( samplecnt );
% offer = 0;
% amass = 1;
% for i = idx+1:samplecnt-idx
%     if( sum_left > sum_right )
%         swallow(i) = slope(i) / 2;
%         offer = offer + slope(i) / 2;
%         amass = 0;
%     else
%         amass = amass  + 1;
%         swallow(i) = slope(i) + amass / 5 * offer;
