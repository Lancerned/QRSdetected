function [ PWavIndex ] = PWavdetection( RpeakIndex, ECGs, Fs )
%P Wave Detection
%Author:        Pan Jiabin
%Data:          2015-11-16
%Description:   
%Include:
%
%
%
[ Samplecnt Recordcnt ] = size( ECGs );
PRegions = zeros( Samplecnt, Recordcnt );
PFlags = zeros( Samplecnt, Recordcnt );
% PWavs = zeros( Samplecnt, Recordcnt );
idxWindow = ceil( 0.1 * Fs );

for j = 1:Recordcnt
    for i = 2:length( RpeakIndex( :,j ) )-1;
        if( RpeakIndex(i,j) > 0 )
            Headpos = RpeakIndex( i,j ) - round( 2.5 * idxWindow );
            %PFlags( Headpos,j ) = 1;
            PFlags( Headpos:Headpos+ceil( 1.5*idxWindow ),j ) = 1;
        end
    end
end

tECGs = FPDiff( ECGs );
for j = 1:Recordcnt
    for i = 1:Samplecnt
        if( PFlags(i,j) == 0 )
            tECGs(i,j) = 0;
            PRegions(i,j) = 0;
        else
            PRegions(i,j) = ECGs(i,j);
        end
    end
end

tECGs = tECGs .* tECGs;
tECGs = mwintegration( tECGs, idxWindow );

for j = 1:Recordcnt
    Pminus = -( 0.1 * Fs );
    threshFrac = 0.3;
    initMax = max( tECGs( 3*Fs:6*Fs,j ) );
    threshArray = [initMax, initMax, initMax, initMax, initMax, initMax, initMax ];
    threshAverage = threshFrac * initMax;
    i = 1;
    PWavcnt = 1;
    for i = RpeakIndex(1):Samplecnt-idxWindow
        if( tECGs(i,j) > threshAverage && i - Pminus > 0.6 * Fs )
            [~,PWavloc] = max( ECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j ) );
            PWavIndex( PWavcnt,j ) = i - 0.5*idxWindow + PWavloc - 1;
            PWavcnt = PWavcnt + 1;
            Pminus = i;
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


