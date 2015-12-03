%Script:            
%Script Function:	1.Count the TP/FP/FN/sensitive/precision of each record
%					2.Count the TP/FP/FN/sensitive/precision of whole records
%					3.Save the TP/FP/FN position of the last Record.
%					(No.3 function Unfinished)
%Author:            Pan Jiabin
%Originally Written:12/01/2015
%Last Changed:      
%Changed by:
clear all;
close all;
clc;
Methods = { 'ModifiedII'; 'QRSdetected' };
% Records = { '100'; '101'; '102'; '103'; '104'; '105'; '106'; '107'; '108'; '109'; '111'; ...
%             '111'; '112'; '113'; '114'; '115'; '116'; '117'; '118'; '119'; '121'; '122'; '123';...
%             '200'; '201'; '202'; '203'; '205'; '207'; '208'; '209'; '210'; ...
%             '212'; '213'; '214'; '215'; '217'; '219'; '220'; '221'; '222'; '223'; '228';...
%             '230'; '231'; '232'; '233'; '234' };
Records = { '100' };
MethodCnt = length( Methods );
RecordCnt = length( Records );
LeadCnt = 2;
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
            DetectedRpeak = RpeakDetectedFunc( Signal( :,LeadIter ), Fs );
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
            Total(LeadIter,MethodIter).TP = Total(LeadIter,MethodIter).TP + TP;
            Total(LeadIter,MethodIter).FP = Total(LeadIter,MethodIter).FP + FP;
            Total(LeadIter,MethodIter).FN = Total(LeadIter,MethodIter).FN + FN;
        end
%         Total(LeadIter).TP = Total(LeadIter).TP + TP;
%         Total(LeadIter).FP = Total(LeadIter).FP + FP;
%         Total(LeadIter).FN = Total(LeadIter).FN + FN;
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
for MethodIter = 1:MethodCnt
    fprintf( '=>=>=>=>=>=>=>=>=>=>=>=>=>=>For Method: %s <=<=<=<=<=<=<=<=<=<=<=<=<=<=\n',...
        cell2mat( Methods( MethodIter ) ) );
    for LeadIter = 1:LeadCnt
        fprintf( '============================================================\n' );
        fprintf( '\nThe whole Detected performance for Lead%d with the Method:%s:\n', LeadIter, cell2mat( Methods(end) ) );
        fprintf( 'TPTotal:		%d\n', Total(LeadIter,MethodIter).TP );
        fprintf( 'FPTotal:		%d\n', Total(LeadIter,MethodIter).FP );
        fprintf( 'FNTotal:		%d\n', Total(LeadIter,MethodIter).FN );
%         Total(LeadIter,MethodIter).Sensitive = Total(LeadIter,MethodIter).TP / ...
%             ( Total(LeadIter,MethodIter).TP + Total(LeadIter,MethodIter).FN );
%         Total(LeadIter,MethodIter).Precision = Total(LeadIter,MethodIter).TP / ...
%             ( Total(LeadIter,MethodIter).TP + Total(LeadIter,MethodIter).FP );
        fprintf( 'Sensitive:    %f\n', Total(LeadIter,MethodIter).Sensitive );
        fprintf( 'Precision:    %f\n', Total(LeadIter,MethodIter).Precision ); 
    end
    fprintf( '===================================================================\n' );
end

