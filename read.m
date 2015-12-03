%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title:     The Main Script For QRS-detection and classify
%Programmer:    Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  11/15/2015
%Last Changed:  12/3/2015
%Changed By:    Pan Jiabin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;close all;clc;
data_dir=[pwd filesep];
addpath(pwd)

recordName = [ data_dir '201' ];
[ Signal, Fs, Siginfo, Atrinfo ]=rddat(recordName);
fprintf( 'Rddat finished.\n');

Signal = BPFilter( Signal );

%[SampleCnt LeadCnt] = size( Signal );
% Rpeak = ModifiedII( Signal, Fs );
% QRSdetected( Signal, Fs );
Feature = KmeansDetected( Signal, Fs );
fprintf( 'QRSdetected finished.\n' ); 
% TWavindex = TWavdetection( Rpeak, Signal, Fs );
% fprintf( 'TWavdetection finished.\n' );
% PWavindex = PWavdetection( Rpeak, Signal, Fs );
% fprintf( 'PWavdetection finished.\n' );
%% PLOT R-PEAK 
plot( Signal( :,1 ) );
hold on
r = Feature(1).Rpeak;
for i = 1:length(r)
    plot( r(i),Signal(r(i),1), 'ro' );
    hold on;
end

% %% PLOT TWav 
% Twav = find( TWavindex(:,1) < 20000 );
% Twav = TWavindex(Twav,1);
% for i = 1:length(Twav)
%     plot( Twav(i),Signal(Twav(i),1), 'ro' );
%     hold on;
% end

%% PlOT ATR
% atr = find( Atrinfo.Time < 600000 );
% ar = Atrinfo.Time( atr );
% for i = 1:length(ar)
%     plot( ar(i),Signal(ar(i),1), 'ko' );
%     hold on;
% end

% Methods = {'ModifiedII' 'QRSdetected'};
% MethodCnt = length( Methods );
% MethodIter = 1;
% while( MethodIter <= MethodCnt )
%     str = cell2mat ( Methods(MethodIter) );
%     fprintf( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n' );
%     fprintf( 'Now calculate the correct rate for Method: %s\n', str );
%     % RpeakDetectedMethod = @ModifiedII;
%     % RpeakDetectedMethod = @QRSdetected;
%     % RpeakDetec tedMethod = { @ModifiedII; @QRSdetected };
%     RpeakDetectedMethod = str2func( str );
%     CorrectRate( RpeakDetectedMethod, Signal, Atrinfo, Fs );
%     MethodIter = MethodIter + 1;
% end
% 



