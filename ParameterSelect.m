%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title:             The Parameter Select Script 
%Programmer:        Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  03/01/2015
%Last Changed:      03/01/2015
%Changed By:        Pan Jiabin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;close all;clc;
data_dir=[pwd filesep];
addpath(pwd)

recordName = [ data_dir '104' ];
[ Signal, Fs, Siginfo, Atrinfo ]=rddat(recordName);

atr = Atrinfo.Time( find( ( Atrinfo.Type > 0 & Atrinfo.Type < 14 ) | Atrinfo.Type == 31 | Atrinfo.Type == 38 ) );
% text( x, y, str );
fprintf( 'Rddat finished.\n');

Signal = BPFilter( Signal );
Signal = WaveTransform( Signal );
fprintf( 'Preprocess finished.\n' );

fprintf( 'Start optimizaiton.\n' );

% [ vector, BestCost ]  = randomoptimize( Signal(:,1), Fs, atr );
domain = [ 0.2 1; 0.2 0.8; 0.2 10; 0.2 10; 1 10 ];
            
[ vector, BestCost ]  = PSOptimize( Signal(:,1), Fs, atr, domain );

vector
BestCost




