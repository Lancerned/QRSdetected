clear all;close all;clc
data_dir=[pwd filesep];
addpath(pwd)

recordName = [ data_dir '100' ];
[ Signal, Fs, Siginfo, Atrinfo ]=rddat(recordName);
fprintf( 'Rddat finished.\n');

%[SampleCnt LeadCnt] = size( Signal );
Rpeak = ModifiedII( Signal, Fs );
fprintf( 'QRSdetected finished.\n' );


%% Old program for Matlab	%%%%%%%%%%%%%%%%%%%%
%TWavindex = TWavdetection( Rpeak, Signal, Fs );
%fprintf( 'TWavdetection finished.\n' );
%PWavindex = PWavdetection( Rpeak, Signal, Fs );
%fprintf( 'PWavdetection finished.\n' );


%% PlOT ATR
% atr = find( Atrinfo.Time < 2000 );
% ar = Atrinfo.Time( atr );
% for i = 1:length(ar)
%     plot( ar(i),Signal(ar(i),1), 'gx' );
%     hold on;
% end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




