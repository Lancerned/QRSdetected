function [ RpeakIndex ] = QRSdetected( ECGs, Fs )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title: QRS Detected Algorithm From The Python
%Programmer:    Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  11/15/2015
%Last Changed:      12/09/2015
%Changed By:        Pan Jiabin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ Samplecnt, Recordcnt ] = size( ECGs );
idxWindow = ceil( Fs*0.1);
tECGs = FPDiff( ECGs );
tECGs = tECGs .* tECGs;
tECGs = mwintegration( tECGs, idxWindow );

for j = 1:Recordcnt
    Tminus = -(0.1*Fs);
    threshFrac = 0.4;
    threshArray = zeros( 7, 1 );
%     initMax = max( tECGs( 3*Fs:6*Fs,j ) );
%     threshArray = [ initMax, initMax, initMax, initMax, initMax, initMax, initMax ];
%     threshAverage = threshFrac * initMax;

    % Modified thresArray initial method.
    for i = 1:7
        init_segment = tECGs( (2*i - 1)*Fs:(2*i + 1 )*Fs, 1 );
        initMax = max( init_segment );
        threshArray(i) = initMax;
    end
    threshAverage = threshFrac * ( sum(threshArray) - min(threshArray) - max(threshArray) ) / 5;
    % Modified secondary threshold.
    last5interval = zeros( 5, 1 );
    last5interval_average = 0;
    secondary_tminus = Tminus;
    % Modified end.
    i = 1;
    Rpeakcnt = 1;
    while( i < Samplecnt )
        if( i > idxWindow && i < Samplecnt - idxWindow )
            if( tECGs(i,j) > threshAverage && ( i - Tminus ) > ( 0.2 * Fs ) )
                [~,QRSloc] = max( abs( ECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j ) ) );
                i = i - 0.5*idxWindow + QRSloc - 1;
                RpeakIndex( Rpeakcnt,j ) = i;
                Tminus = i;
%                 RpeakIndex( Rpeakcnt,j ) = i - 0.5*idxWindow + QRSloc - 1;
%                 Tminus = i;
%                 threshArray(1) = [];
%                 threshArray(end+1) = max( tECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j) );
                threshArray(1:end-1) = threshArray( 2:end );
                threshArray( end ) = max( tECGs( (i - 0.5*idxWindow ):( i + 0.5*idxWindow ), j ) );
                threshAverage = threshFrac * ( sum(threshArray) - min(threshArray) - max(threshArray) ) / 5;
            % Modified for secondary threshold.
                if( Rpeakcnt > 1)
                    last5interval( 1:4 ) = last5interval( 2:5 );
                    last5interval( end ) = max( 0.2 * Fs, RpeakIndex( Rpeakcnt,j ) - RpeakIndex( Rpeakcnt - 1,j ) );
                    last5interval_average = sum( last5interval ) / 5;
                end
                Rpeakcnt = Rpeakcnt + 1;

            elseif( Rpeakcnt > 6 & ( i - Tminus > 1.6 * last5interval_average ) & i - secondary_tminus > 0.2 *Fs )
                secondary_threshold = threshAverage * 0.6;
                iter = RpeakIndex( Rpeakcnt - 1,j );
                while( iter < i )
                    if( tECGs( iter,j ) > secondary_threshold && ( iter - Tminus ) > 0.2 * Fs )
                        [~,QRSloc] = max( abs( ECGs( (iter-0.5*idxWindow):(iter+0.5*idxWindow), j ) ) );
                        RpeakIndex( Rpeakcnt,j ) = iter - 0.5*idxWindow + QRSloc - 1;
                        Tminus = iter;
                        threshArray(1:end-1) = threshArray( 2:end );
                        threshArray( end ) = max( tECGs( (iter - 0.5*idxWindow ):( iter + 0.5*idxWindow ), j ) );
                        threshAverage = threshFrac * ( sum(threshArray) - min(threshArray) - max(threshArray) ) / 5;
                        if( Rpeakcnt > 1)
                            last5interval( 1:4 ) = last5interval( 2:5 );
                            last5interval( end ) = RpeakIndex( Rpeakcnt,j ) - RpeakIndex( Rpeakcnt - 1,j );
                            last5interval_average = sum( last5interval ) / 5;
                        end
                        Rpeakcnt = Rpeakcnt + 1;
                    end
                    iter = iter + 1;
                end
                secondary_tminus = i;
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


