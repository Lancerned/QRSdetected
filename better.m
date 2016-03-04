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

recordName = [ data_dir '108' ];
[ Signal, Fs, Siginfo, Atrinfo ]=rddat(recordName);

atr = Atrinfo.Time( find( ( Atrinfo.Type > 0 & Atrinfo.Type < 14 ) | Atrinfo.Type == 31 | Atrinfo.Type == 38 ) );
% text( x, y, str );
fprintf( 'Rddat finished.\n');

Signal = BPFilter( Signal );
Signal = WaveTransform( Signal );
%[SampleCnt LeadCnt] = size( Signal );
% Rpeak = ModifiedII( Signal, Fs );
% Rpeak = QRSdetected( Signal, Fs );
% Feature = KmeansDetected( Signal, Fs );
best = 0;
% for i = 1:7
%     for j = 1:10

% Vector = [ 0.3012 0.9506 0.4606 0.2876 0.0846 0.5822 0.1531 ];
Vector = [ 0.8302 0.0168 0.2641 0.1419 0.0330 0.2893 0.8939];
% Vector(i) = 0.1 * j;
% 
%         fprintf( 'i = %f\tj = %f\n', i, Vector(i) );

Rpeak = KNNdetected( Signal, Fs, Vector );
fprintf( 'QRSdetected finished.\n' ); 


Rpeak = Rpeak( find(Rpeak) );
DetectedRpeakIter = 1;
AtrRpeakIter = 1;
DetectedRpeakCnt = length( Rpeak(:,1) );
AtrRpeakCnt = length( atr );
% plot( Signal( :,1 ) );
% hold on
TP = 0;
FP = 0;
FN = 0;
while( DetectedRpeakIter <= DetectedRpeakCnt & AtrRpeakIter < AtrRpeakCnt  )
    if( abs( Rpeak( DetectedRpeakIter ) - atr( AtrRpeakIter ) ) < 0.15 *  Fs ) 
%         text( Rpeak( DetectedRpeakIter ), Signal( Rpeak(DetectedRpeakIter),1 ), 'TP' );
%         hold on;
        TP = TP + 1;
        DetectedRpeakIter = DetectedRpeakIter + 1;
        AtrRpeakIter = AtrRpeakIter + 1;
    elseif( Rpeak( DetectedRpeakIter ) < atr( AtrRpeakIter ) )
%         text( Rpeak( DetectedRpeakIter ), Signal( Rpeak(DetectedRpeakIter),1 ), 'FP' );
        hold on;
        FP = FP + 1;
        DetectedRpeakIter = DetectedRpeakIter + 1;
    else
%         text( atr( AtrRpeakIter ), Signal( atr(AtrRpeakIter),1 ), 'FN' );
        FN = FN + 1;
        AtrRpeakIter = AtrRpeakIter + 1;
    end
end
fprintf( 'TP = %d\n', TP );
fprintf( 'FP = %d\n', FP );
fprintf( 'FN = %d\n', FN );
fprintf( 'value = %d\n', TP-FP-FN );
    if ( TP - FP - FN ) > best
        temp = Vector;
    end
%     end
% end

temp
% TWavindex = TWavdetection( Rpeak, Signal, Fs );
% fprintf( 'TWavdetection finished.\n' );
% PWavindex = PWavdetection( Rpeak, Signal, Fs );
% fprintf( 'PWavdetection finished.\n' );
% %% PLOT R-PEAK 
% plot( Signal( :,1 ) );
% hold on
% % r = Feature(1).Rpeak;
% r = Rpeak( find(Rpeak(:,1)),1 );
% for i = 1:length(r)
%     plot( r(i),Signal(r(i),1), 'ro' );
%     hold on;
% end

% %% PLOT TWav 
% Twav = Feature(1).Tpeak;
% for i = 1:length(Twav)
%     plot( Twav(i),Signal(Twav(i),1), 'ro' );
%     hold on;
% end

%% PlOT ATR
% for i = 1:length(atr)
%     plot( atr(i),Signal(atr(i),1), 'ko' );
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



