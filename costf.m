function [ cost ] = costf( Rpeak, Fs, atr )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

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
%         hold on;
        FP = FP + 1;
        DetectedRpeakIter = DetectedRpeakIter + 1;
    else
%         text( atr( AtrRpeakIter ), Signal( atr(AtrRpeakIter),1 ), 'FN' );
        FN = FN + 1;
        AtrRpeakIter = AtrRpeakIter + 1;
    end
end

cost = TP - FP - FN;

end

