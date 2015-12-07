function [ Result ] = CorrectCount( Signal, Fs, Method, Atrinfo )
% Title:                1.Count the TP/FP/FN/sensitive/precision wiht the corresponding input
%                        record and method 
% Unfinished Problem:   1.仅能保留最后一个检测算法的整体检测统计（导联，方法）显示index问题
%                       2.不能保存出错位置信息
% Author:               Pan Jiabin
% Originally Written:   12/07/2015
% Last Changed:      
% Changed by:        

TP = 0;
FN = 0;
FP = 0;

RpeakDetectedFunc = str2func( Method );
DetectedRpeak = RpeakDetectedFunc( Signal, Fs );
AtrRpeak = Atrinfo.Time( find( Atrinfo.Type > 0 & Atrinfo.Type < 14 ) );

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

Sensitive = TP / ( TP + FN );
Precision = TP / ( TP + FP );

Result.TP = TP;
Result.FP = FP;
Result.FN = FN;
Result.Sensitive = Sensitive;
Result.Precision = Precision;

end

