%Script:            
%Script Function:	1.Count the TP/FP/FN/sensitive/precision of each record
%					2.Count the TP/FP/FN/sensitive/precision of whole records
%					3.Save the TP/FP/FN position of the last Record.
%					(No.3 function Unfinished)
%Unfinished Problem:1.仅能保留最后一个检测算法的整体检测统计（导联，方法）显示index问题
%                   2.不能保存出错位置信息
%Author:            Pan Jiabin
%Originally Written:12/01/2015
%Last Changed:      
%Changed by:        Pan Jiabin
clear all;
close all;
clc;
% Methods = { 'QRSdetected'; 'ModifiedII':'KmeansRpeak' };
Methods = { 'ModifiedII' };
Records = { '100'; '101'; '102'; '103'; '104'; '105'; '106'; '107'; '108'; '109'; '111'; ...
            '111'; '112'; '113'; '114'; '115'; '116'; '117'; '118'; '119'; '121'; '122'; '123';...
            '200'; '201'; '202'; '203'; '205'; '207'; '208'; '209'; '210'; ...
            '212'; '213'; '214'; '215'; '217'; '219'; '220'; '221'; '222'; '223'; '228';...
            '230'; '231'; '232'; '233'; '234' };

MethodCnt = length( Methods );
RecordCnt = length( Records );
LeadCnt = 1;
% TPTotal = 0;
% FNTotal = 0;
% FPTotal = 0;
for LeadIter = 1:LeadCnt
    Total(LeadIter).TP = 0;
    Total(LeadIter).FP = 0;
    Total(LeadIter).FN = 0;
    Total(LeadIter).Sensitive = 0;
    Total(LeadIter).Precision = 0;
end

%CorrectInfo{   Record = 'Record Num';
%               
bpcnt = 1;
for RecordIter = 1:RecordCnt
	str = cell2mat( Records( RecordIter) );
	[ Signal, Fs, Siginfo, Atrinfo ]=rddat( str );
	fprintf( '===========================================================\n' );
	fprintf( 'Now we calculate the %s record\n', str );
    %LeadCnt = size( Signal, 2 );
    for LeadIter = 1:LeadCnt
        fprintf( 'With the Lead %d:\n', LeadIter );
        MethodIter = 1;
        for MethodIter = 1:MethodCnt
            TP = 0;
            FN = 0;
            FP = 0;
            str = cell2mat( Methods( MethodIter ) );
            fprintf( 'With the Methods: %s\n', str );
            RpeakDetectedFunc = str2func( str );
            Filtered = BPFilter( Signal( :,LeadIter ) );
            Filtered = WaveTransform( Filtered );
%             DetectedRpeak = RpeakDetectedFunc( Signal( :,LeadIter ), Fs );
            DetectedRpeak = RpeakDetectedFunc( Filtered, Fs );
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
		
%             TPTotal = TPTotal + TP;
%             FPTotal = FPTotal + FP;
%             FNTotal = FNTotal + FN;
            Sensitive = TP / ( TP + FN );
            Precision = TP / ( TP + FP );
            fprintf( 'TP:           %d\n', TP );
            fprintf( 'FP:           %d\n', FP );
            fprintf( 'FN:           %d\n', FN );
        	fprintf( 'Sensitive:    %f\n', Sensitive );
        	fprintf( 'Precision:    %f\n', Precision );
            
            % count the bad performance record.
            if( LeadIter == 1 & ( Sensitive < 0.99 || Precision < 0.99 ) )
                bprecord( bpcnt ).file = { cell2mat( Records( RecordIter) ) };
                bprecord( bpcnt ).TP = TP;
                bprecord( bpcnt ).FP = FP;
                bprecord( bpcnt ).FN = FN;
                bprecord( bpcnt ).Sensitive = Sensitive;
                bprecord( bpcnt ).Precision = Precision;
                bpcnt = bpcnt + 1;
            end
%             Total(LeadIter).TP = Total(LeadIter).TP + TP;
%             Total(LeadIter).FP = Total(LeadIter).FP + FP;
%             Total(LeadIter).FN = Total(LeadIter).FN + FN;
        end
        Total(LeadIter).TP = Total(LeadIter).TP + TP;
        Total(LeadIter).FP = Total(LeadIter).FP + FP;
        Total(LeadIter).FN = Total(LeadIter).FN + FN;
        fprintf( '-------------------------------------------\n' );
    end
end

% fprintf( '\nThe whole Detected performance:\n' );

% Sensitive = TPTotal / ( TPTotal + FNTotal );
% Precision = TPTotal / ( TPTotal + FPTotal );

% fprintf( 'TPTotal:		%d\n', TPTotal );
% fprintf( 'FPTotal:		%d\n', FPTotal );
% fprintf( 'FNTotal:		%d\n', FNTotal );
% fprintf( 'Sensitive:    %f\n', Sensitive );
% fprintf( 'Precision:    %f\n', Precision );

for LeadIter = 1:LeadCnt
    fprintf( '============================================================\n' );
    fprintf( '\nThe whole Detected performance for Lead%d with the %s Method:\n', LeadIter, cell2mat( Methods(end) ) );
    fprintf( 'TPTotal:		%d\n', Total(LeadIter).TP );
    fprintf( 'FPTotal:		%d\n', Total(LeadIter).FP );
    fprintf( 'FNTotal:		%d\n', Total(LeadIter).FN );
    Total(LeadIter).Sensitive = Total(LeadIter).TP / ( Total(LeadIter).TP + Total(LeadIter).FN );
    Total(LeadIter).Precision = Total(LeadIter).TP / ( Total(LeadIter).TP + Total(LeadIter).FP );
    fprintf( 'Sensitive:    %f\n', Total(LeadIter).Sensitive );
    fprintf( 'Precision:    %f\n', Total(LeadIter).Precision ); 
end

bpcnt = bpcnt - 1;
fprintf( 'The %d bad performance records:\n',bpcnt );
disp( 'Record TP     FP     FN     Sensitive    Precison' );
for i = 1:bpcnt
    fprintf( '%s      %-7d\t%-7d\t%-7d\t%f\t%f\n', cell2mat( bprecord( i ).file ), bprecord( i ).TP, ...
        bprecord( i ).FP, bprecord( i ).FN, bprecord(i).Sensitive, bprecord(i).Precision );
end
