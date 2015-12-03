function [ TWavIndex ] = TWavdetection( RpeakIndex, ECGs, Fs )
%T Wave Detection
%Author:        Pan Jiabin
%Data:          2015-11-16
%Description:   
%Include:
%
%
%
[ Samplecnt Recordcnt ] = size( ECGs );
TRegions = zeros( Samplecnt, Recordcnt );
TFlags = zeros( Samplecnt, Recordcnt );
% TWavs = zeros( Samplecnt, Recordcnt );
idxWindow = ceil( 0.1 * Fs );

for j = 1:Recordcnt
    for i = 1:length( RpeakIndex( :,j ) )- 1
        Headpos = RpeakIndex( i,j ) + 3 * idxWindow;
        TFlags( Headpos:Headpos+ceil( 1.5*idxWindow ),j ) = 1;
    end
end

tECGs = FPDiff( ECGs );
for j = 1:Recordcnt
    for i = 1:Samplecnt
        if( TFlags(i,j) == 0 )
            tECGs(i,j) = 0;
            TRegions(i,j) = 0;
        else
            TRegions(i,j) = ECGs(i,j);
        end
    end
end

tECGs = tECGs .* tECGs;
tECGs = mwintegration( tECGs, idxWindow );

for j = 1:Recordcnt
    Tminus = -( 0.1 * Fs );
    threshFrac = 0.3;
    initMax = max( tECGs( 3*Fs:6*Fs,j ) );
    threshArray = [initMax, initMax, initMax, initMax, initMax, initMax, initMax ];
    threshAverage = threshFrac * initMax;
    i = 1;
    TWavcnt = 1;
    for i = RpeakIndex(1):Samplecnt-idxWindow
        if( tECGs(i,j) > threshAverage && i - Tminus > 0.6 * Fs )
            [~,TWavloc] = max( ECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j ) );
            TWavIndex( TWavcnt,j ) = i - 0.5*idxWindow + TWavloc - 1;
            TWavcnt = TWavcnt + 1;
            Tminus = i;
            threshArray(1) = [];
            threshArray(end+1) = max( tECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j) );
            threshAverage = threshFrac * ( sum(threshArray) - min(threshArray) - max(threshArray) ) / 5;
        end
    end
end

    
end


function iECGs = mwintegration( ECGs, idxWindow )
[Samplecnt Recordcnt] = size(ECGs);
iECGs = zeros( Samplecnt, Recordcnt );

for j = 1:Recordcnt
    for i = idxWindow+1:Samplecnt
        iECGs(i,j) = sum( ECGs( i-idxWindow:i,j ) );
    end
end
end


