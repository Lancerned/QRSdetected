function [ ] = CorrectRate( Methods, Records )
%Script Function:	1.Count the TP/FP/FN/sensitive/precision of each record
%					2.Count the TP/FP/FN/sensitive/precision of whole records
%					3.Save the TP/FP/FN position of the last Record.
%Author:		Pan Jiabin
%Originally Written:	12/01/2015
%Last Changed:	
%Changed by:
clear;
Methods = { 'ModifiedII'; 'QRSdetected' };
Records = [ 100 201 ];

MethodCnt = length( Methods );
RecordCnt = length( Records );
TPTotal = 0;
FNTotal = 0;
FPTotal = 0;

RecordIter = 1;
while( RecordIter < RecordCnt )
	str = cell2mat( Records( RecordIter) );
	[ Signal, Fs, Siginfo, Atrinfo ]=rddat( str );
	fprintf( '%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%\n' );
	fprintf( 'Now we calculate the %s record\n', str );
	MethodIter = 1;
	TP = 0;
	FN = 0;
	FP = 0;
	while( MethodIter < MethodCnt )
		str = cell2mat( Methods( MethodIter ) );
		fprintf( 'With the Methods: %s\n', str );
		RpeakDetectedFunc = str2func( str );
		DetectedRpeak = RpeakDetectedFunc( Signal, Fs );
		AtrRpeak = Atrinfo.Time( find( Atrinfo.Type > 0 & Atrinfo.Type < 15 ) );
		
		DetectedRpeakCnt = length( DetectedRpeak );
		AtrRpeak = length( AtrRpeak );

		DetectedRpeakIter = 1;
		AtrRpeakIter = 1;

		while( DetectedRpeakIter <= DetectedRpeakCnt & AtrRpeakIter < AterRpeakCnt )
			if( abs( DetectedRpeak( DetectedRpeakIter ) - AtrRpeak( AtrRpeakIter ) ) < 0.15 *  Fs ) 
				TP = TP + 1;
				DetectedRpeakIter = DetectedRpeakIter + 1;
				AtrRpeakIter = AtrRpeakIter + 1;
			else if( DetectedRpeak( DetectedRpeakIter ) < AtrRpeak( AtrRpeakIter ) )
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
		
		TPTotal = TPTotal + TP;
		FPTotal = FPTotal + FP;
		FNTotal = FNTotal + FN;
		Sensitive = TP / ( TP + FN );
		Precision = TP / ( TP + FP );
		fprintf( 'TP:		%d\n', TP );
		fprintf( 'FP:		%d\n', FP );
		fprintf( 'FN:		%d\n', FN );
		fprintf( 'Sensitive:%s\n', Sensitive );
		fprintf( 'Precision:%s\n', Precision );
		
		CorrectRate(i).FN = FN;
		CorrectRate(Rcord

		

		MethodIter = MethodIter + 1;

	MethodIter = MethodIter + 1;



