clear all;close all;clc;
data_dir=[pwd filesep];
addpath(pwd)

recordName = [ data_dir '108' ];
[ Signal, Fs, Siginfo, Atrinfo ]=rddat(recordName);

atr = Atrinfo.Time( find( ( Atrinfo.Type > 0 & Atrinfo.Type < 14 ) | Atrinfo.Type == 31 | Atrinfo.Type == 38 ) );
% text( x, y, str );
fprintf( 'Rddat finished.\n');

Signal = BPFilter( Signal );
Signal = WaveTransform( Signal );

signal = Signal( 1:50000, 1 );
Rpeak = QRSdetected( signal, Fs );

plot( signal );
hold on;
for i = 1:length(Rpeak )
    plot( Rpeak(i), signal(Rpeak(i)), 'ro' );
    hold on;
end
QRSInterval = 80 / Fs; % ~= 0.22 s

RMSRpeak = zeros( length(Rpeak),1 );

for iter = 1:length(RMSRpeak)
    RMSRpeak( iter ) = RMSCalculate( signal, Rpeak(iter) - 40, Rpeak(iter) + 40 );
end




