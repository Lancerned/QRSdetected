function [] = CorrectRate( Method, Signal, Atrinfo, Fs )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title:     Calculate CorrectRate of Rpeak-Detection
%Programmer:    Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  11/30/2015
%Last Changed:  11/30/2015
%Changed By:    Pan Jiabin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Rpeak = Method( Signal, Fs );

for lead = 1:size( Rpeak,2 )
    TP = [];
    FP = [];
    FN = [];
    DetectedRpeak = Rpeak( :, lead );  %Remove unuseful data
    AtrRpeak = Atrinfo.Time(  Atrinfo.Type > 0 & Atrinfo.Type < 14  );
    DetectedCnt = length( DetectedRpeak );
    AtrCnt = length(AtrRpeak);
    DetectedIter = 1;
    AtrIter = 1;
    while( DetectedIter <= DetectedCnt & AtrIter < AtrCnt )
        if( abs( DetectedRpeak( DetectedIter ) - AtrRpeak( AtrIter ) ) < 0.15 * Fs )
            TP = [TP AtrRpeak(AtrIter)];
            DetectedIter = DetectedIter + 1;
            AtrIter = AtrIter + 1;
        elseif( DetectedRpeak( DetectedIter ) < AtrRpeak( AtrIter ) )
            FP = [FP DetectedRpeak( DetectedIter )];
            DetectedIter = DetectedIter + 1;
        else
            FN = [FN AtrRpeak( AtrIter )];
            AtrIter = AtrIter + 1;
        end
    end
    while( DetectedIter <= DetectedCnt )
        FP = [FP DetectedRpeak( DetectedIter )];
        DetectedIter = DetectedIter + 1;
    end
    while( AtrIter <= AtrCnt )
        FN = [FN AtrRpeak( AtrIter )];
        AtrIter = AtrIter + 1;
    end
    
    
    TPCnt = length( TP );
    FPCnt = length( FP );
    FNCnt = length( FN );
    Sensitive = TPCnt / ( TPCnt + FNCnt ); 
    Precision = TPCnt / ( TPCnt + FPCnt );
    fprintf( 'Lead %d Rpeak detected Result:\n', lead );
    fprintf( 'FPCnt = %d\n', FPCnt );
    fprintf( 'FNCnt = %d\n', FNCnt );
    fprintf( 'TPCnt = %d\n', TPCnt );
    fprintf( 'Sensitive = %f\n', Sensitive );
    fprintf( 'Precision = %f\n', Precision );

end
end

