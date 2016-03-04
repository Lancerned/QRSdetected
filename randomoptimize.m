function [ bestvector, bestcost ] = randomoptimize( Signal, Fs, atr )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
bestcost = 0;
for i = 1:2000
    clc;
    fprintf( 'RandomOptimize: %d\n', i );
    vector = rand( 1, 7 );
    Rpeak = KNNdetected( Signal, Fs, vector );
    cost = costf( Rpeak, Fs, atr );
    if cost > bestcost
        bestvector = vector;
        bestcost = cost;
    end
end
fprintf( 'RandomOptimize Finished.\n' );
end

