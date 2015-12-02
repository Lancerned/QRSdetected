clear all;close all;clc
data_dir=[pwd filesep];
addpath(pwd)

recordName = [ data_dir '100' ];
fprintf( '%s \n', recordName );

[ Signal, Fs, Siginfo, Atrinfo ]=rddat(recordName);
fprintf( 'rddat finished.\n' );

if( size( Atrinfo.Type ) == size( Atrinfo.Time ) )
	fprintf( 'Type counts is eq to Time counts.\n' );
end

RpeakIndex = ModifiedII( Signal( :,1 ), Fs );
size( RpeakIndex );

plot( Signal );


