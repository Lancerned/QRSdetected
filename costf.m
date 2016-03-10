function [ cost ] = costf( Records, Method, vector )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

RecordCnt = length( Records );
TP = 0;
FN = 0;
FP = 0;

for iterRecord = 1:RecordCnt
    
	str = cell2mat( Records( iterRecord ) );
	[ Signal, Fs, Siginfo, Atrinfo ]=rddat( str );
    

    RpeakDetectedFunc = str2func( Method );
    Filtered = BPFilter( Signal( :,1 ) );
    Filtered = WaveTransform( Filtered );
    DetectedRpeak = RpeakDetectedFunc( Filtered, Fs, vector );
    DetectedRpeak = DetectedRpeak( find(DetectedRpeak(:,1)) );
    
    AtrRpeak = Atrinfo.Time( find( ( Atrinfo.Type > 0 & Atrinfo.Type < 14 ) ...
                | Atrinfo.Type == 31 | Atrinfo.Type == 38 ) );
		
    DetectedRpeakCnt = length( DetectedRpeak );
    AtrRpeakCnt = length( AtrRpeak );

    DetectedRpeakIter = 1;
    AtrRpeakIter = 1;

    while( DetectedRpeakIter <= DetectedRpeakCnt & AtrRpeakIter < AtrRpeakCnt )
        if( abs( DetectedRpeak( DetectedRpeakIter ) - AtrRpeak( AtrRpeakIter ) ) < 0.15 *  Fs ) 
            TP = TP + 1;
            DetectedRpeakIter = DetectedRpeakIter + 1;
            AtrRpeakIter = AtrRpeakIter + 1;
        elseif( DetectedRpeak( DetectedRpeakIter ) < AtrRpeak( AtrRpeakIter ) )
            FP = FP + 1;
            DetectedRpeakIter = DetectedRpeakIter + 1;
        else
            FN = FN + 1;
            AtrRpeakIter = AtrRpeakIter + 1;
        end
    end
    
    while( DetectedRpeakIter <= DetectedRpeakCnt )
        FP = FP + 1;
        DetectedRpeakIter = DetectedRpeakIter + 1;
    end
    
    while( AtrRpeakIter <= AtrRpeakCnt )
        FN = FN + 1;
        AtrRpeakIter = AtrRpeakIter + 1;
    end
    
end

cost = TP - FP - FN;

end

