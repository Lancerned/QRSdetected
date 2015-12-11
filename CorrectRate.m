%Script Function:	1.Count the TP/FP/FN/sensitive/precision of each record
%					2.Count the TP/FP/FN/sensitive/precision of whole records
%					3.Save the TP/FP/FN position of the last Record.
%					(No.3 function Unfinished)
%Unfinished Problem:1.不能保存出错位置信息
%Author:            Pan Jiabin
%Originally Written:12/01/2015
%Last Changed:      12/07/2015
%Changed by:        Pan Jiabin
clear all;
close all;
clc;
% Methods = { 'QRSdetected'; 'ModifiedII';'KmeansRpeak' };
% Records = { '100'; '101'; '102'; '103'; '104'; '105'; '106'; '107'; '108'; '109'; '111'; ...
%             '124'; '112'; '113'; '114'; '115'; '116'; '117'; '118'; '119'; '121'; '122'; '123';...
%             '200'; '201'; '202'; '203'; '205'; '207'; '208'; '209'; '210'; ...
%             '212'; '213'; '214'; '215'; '217'; '219'; '220'; '221'; '222'; '223'; '228';...
%             '230'; '231'; '232'; '233'; '234' };
% 
Methods = { 'QRSdetected' };
Records = { '108' };

MethodCnt = length( Methods );
RecordCnt = length( Records );
LeadCnt = 1;

for RecordIter = 1:RecordCnt
    fprintf( 'Calculating now, Please wait for a moment.\n.' );
	str = cell2mat( Records( RecordIter) );
	[ Signal, Fs, Siginfo, Atrinfo ]=rddat( str );
% 	fprintf( '===========================================================\n' );
% 	fprintf( 'Now we calculate the %s record\n', str );
    for LeadIter = 1:LeadCnt
%         fprintf( 'With the Lead %d:\n', LeadIter );
        MethodIter = 1;
        for MethodIter = 1:MethodCnt
            str = cell2mat( Methods( MethodIter ) );
%             fprintf( 'With the Methods: %s\n', str );
            Filtered = BPFilter( Signal( :,LeadIter ) );
            Filtered = WaveTransform( Filtered );
            Result = CorrectCount( Filtered, Fs, str, Atrinfo );
            ComparedInfo(RecordIter,LeadIter,MethodIter).TP = Result.TP;
            ComparedInfo(RecordIter,LeadIter,MethodIter).FP = Result.FP;
            ComparedInfo(RecordIter,LeadIter,MethodIter).FN = Result.FN;
            ComparedInfo(RecordIter,LeadIter,MethodIter).Sensitive = Result.Sensitive;
            ComparedInfo(RecordIter,LeadIter,MethodIter).Precision = Result.Precision;  
            fprintf( '.' );
        end
    end
    clc;
end



for LeadIter = 1:LeadCnt
    fprintf( 'Lead%d detected Result.\n', LeadIter );
    fprintf( 'Method:\t\tTotalTP\tTotalFP\tTotalFN\tSensitive\tPrecision\t\n' );
    for MethodIter = 1:MethodCnt
        TotalTP = 0;
        TotalFP = 0;
        TotalFN = 0;
        for RecordIter = 1:RecordCnt
            TotalTP = TotalTP + ComparedInfo( RecordIter,LeadIter,MethodIter ).TP;
            TotalFP = TotalFP + ComparedInfo( RecordIter,LeadIter,MethodIter ).FP;
            TotalFN = TotalFN + ComparedInfo( RecordIter,LeadIter,MethodIter ).FN;
        end
        Sensitive = TotalTP / ( TotalTP + TotalFN );
        Precision = TotalTP / ( TotalTP + TotalFP );
         str = cell2mat( Methods( MethodIter ) );
        fprintf( '%s\t%7d\t%7d\t%7d\t%f\t%f\n', str, TotalTP, TotalFP, TotalFN, Sensitive, Precision );
    end
end
