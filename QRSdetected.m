function [ RpeakIndex ] = QRSdetected( ECGs, Fs )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title: QRS Detected Algorithm From The Python
%Programmer:    Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  11/15/2015
%Last Changed:  11/30/2015
%Changed By:    Pan Jiabin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ Samplecnt, Recordcnt ] = size( ECGs );
idxWindow = ceil( Fs*0.1);
tECGs = FPDiff( ECGs );
tECGs = tECGs .* tECGs;
tECGs = mwintegration( tECGs, idxWindow );

for j = 1:Recordcnt
    Tminus = -(0.1*Fs);
    threshFrac = 0.5;
    initMax = max( tECGs( 3*Fs:6*Fs,j ) );
    threshArray = [ initMax, initMax, initMax, initMax, initMax, initMax, initMax ];
    threshAverage = threshFrac * initMax;
    i = 1;
    Rpeakcnt = 1;
    while( i < Samplecnt )
        if( i > idxWindow && i < Samplecnt - idxWindow )
            if( tECGs(i,j) > threshAverage && ( i - Tminus ) > ( 0.2 * Fs ) )
                [~,QRSloc] = max( abs( ECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j ) ) );
                RpeakIndex( Rpeakcnt,j ) = i - 0.5*idxWindow + QRSloc - 1;
                Rpeakcnt = Rpeakcnt + 1;
                Tminus = i;
                threshArray(1) = [];
                threshArray(end+1) = max( tECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j) );
                threshAverage = threshFrac * ( sum(threshArray) - min(threshArray) - max(threshArray) ) / 5;
            end
        end
        i = i + 1;
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


