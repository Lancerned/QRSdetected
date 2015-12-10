function [ Samples, Frq, Siginfo, AtrInfo ] = rddat( RecordName )
%Title: Read the ECG data from MIT-BIH with the .dat format
%Programmer:        Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  11/15/2015
%Last Changed:      11/30/2015
%Changed by:        Pan
%Struct:            Siginfo = { Format, Baseline, Gain, Description };
%                   Atrinfo = { Type, Time };


defgain = 200;
fid = fopen( [ RecordName '.hea' ], 'rt' );
if( fid == -1 )
	error( [ 'Could not open file: ' RecordName '.hea' ] );
end

%Skip any commit lines
str = fgetl( fid );
while( strcmp( str(1), '#' ) )
	str = fgetl( fid );
end

%Process Record Line Info
info = textscan( str, '%s %u %f %u' );
% FileName = info{ 1 };
LeadCnt = info{ 2 };	%	Numbers of Lead
Frq	= info{ 3 };
SampleCnt = info{ 4 };


%Process Signal Specification lines. Assumes no comments between lines.
Siginfo = [];
for m = 1:LeadCnt
	str = fgetl( fid );
	info = textscan( str, '%s %u %f %u %f %f %d %d %s' );
	%	201.dat		212		200		11			1024		972			-519		0	MLII
	%	filename	format	ADC     ADCppi      ADCzero 	first_value
	Siginfo(m).Format = info{ 2 };
	Siginfo(m).Gain = info{ 3 };
	Siginfo(m).Baseline = info{ 5 };
	Siginfo(m).Description = info{ 9 };
end
fclose( fid );

% Read the 212 Format data.
if( Siginfo(m).Format == 212 )
    fid = fopen( [ RecordName '.dat' ], 'rb' );
    if( fid == -1 )
        error( [ 'Could not open file: ' RecordName '.dat' ] );
    end

    data = fread(  fid, [ 3, inf ], 'uint8' );
    fclose( fid );
    Sample1H = bitand( data( 2,: ), 15 );
    Sample2H = bitshift( data( 2,: ), -4 );
    Sample1 = Sample1H .* 256 + data( 1,: );
    Sample2 = Sample2H .* 256 + data( 3,: );

    Sample1 = ( Sample1 - Siginfo(1).Baseline ) ./ Siginfo(1).Gain;
    Sample2 = ( Sample2 - Siginfo(2).Baseline ) ./ Siginfo(2).Gain;

    Samples = [ Sample1' Sample2' ];
end

% Read the 16 Format data.
if( Siginfo(m).Format == 16 )
    fid = fopen( [ RecordName '.dat' ], 'rb' );
    if( fid == -1 )
        error( [ 'Could not open file: ' RecordName '.dat' ] );
    end

    data = fread(  fid, [ LeadCnt, inf ], 'int16' );
    fclose( fid );
    Samples = zeros( SampleCnt,LeadCnt );
    for iter = 1:LeadCnt
        temp_sig = data( iter,: );
        temp_sig = ( temp_sig - Siginfo(iter).Baseline ) ./ Siginfo(1).Gain;
        temp_sig = temp_sig';
        Samples( :,iter ) = temp_sig;
    end
end
   

fid = fopen( [ RecordName '.atr' ], 'rb' );
if( fid == -1 )
    error( [ 'Could not open file: ' RecordName '.dat' ] );
end
data = fread(  fid, inf, 'int8' );
fclose( fid );

% if( data(1) ~= 0 )
    fid = fopen( [ RecordName '.atr' ], 'rb' );
    if( fid == -1 )
        error( [ 'Could not open file: ' RecordName '.dat' ] );
    end
    data = fread(  fid, inf, 'uint16' );
    PastTime = 0;
    AtrInfo = [];
    AtrIndex = 1;
    i = 1;
    while( i <= length(data) )
        CodeType = bitshift( data(i), -10 );
        CodeTime = bitand( data(i), 1023 );
        if( CodeType <= 41 )
            AtrInfo.Type( AtrIndex ) = CodeType;
            PastTime = PastTime + CodeTime;
            AtrInfo.Time( AtrIndex ) = PastTime;  
            AtrIndex = AtrIndex + 1;
            else if( CodeType == 59 )
                    CodeType = bitshift( data( i+3 ), -10 );
                    CodeTime = data( i+1 ) * 2^16 + data( i+2 );
                    AtrInfo.Type( AtrIndex ) = CodeType;
                    PastTime = PastTime + CodeTime;
                    AtrInfo.Time( AtrIndex ) = PastTime;
                    AtrIndex = AtrIndex + 1;
                    i = i + 3;
                else if( CodeType == 63 )
                        if( mod( CodeTime,2 ) == 1 )
                            CodeTime = CodeTime + 1;
                        end
                         i = i + CodeTime / 2;
                    end
                end
        end
        i = i + 1;
    end
    fclose( fid );
% else
%     error( 'Can not read AHA format .atr file now.\n' );
% end
%     






