function [ RpeakIndex ] = KNNdetected( ECGs, Fs, para )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title: QRS Detected Algorithm From The Python
%Programmer:    Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  11/15/2015
%Last Changed:      12/09/2015
%Changed By:        Pan Jiabin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vector = [ 0.2776 0.4116 0.5701 0.7272 0.8670 0.9641 1.0000 ];

if nargin < 3
    threshFrac = 0.6499;
    threshFrac2 = 0.3;
    lamda1 = 9.6265;             % For time 
    lamda2 = 2.4925;             % For peak
    lamda  = 4.8504;
else
    threshFrac = para(1);
    threshFrac2 = para(2);
    lamda1 = para(3);
    lamda2 = para(4);
    lamda  = para(5);
end

[ Samplecnt, Recordcnt ] = size( ECGs );
idxWindow = ceil( Fs*0.1);
tECGs = FPDiff( ECGs );
% tECGs = tECGs .* tECGs;
tECGs = abs( tECGs );
tECGs = mwintegration( tECGs, idxWindow );
for j = 1:Recordcnt
    Tminus = -(0.1*Fs);
    threshArray = zeros( 7, 1 );


    % Modified thresArray initial method.
    for i = 1:7
        init_segment = tECGs( (2*i - 1)*Fs:(2*i + 1 )*Fs, j );
        initMax = max( init_segment );
        threshArray(i) = initMax;
    end
    threshold = threshFrac * ( sum(threshArray) - min(threshArray) - max(threshArray) ) / 5;
    % Modified secondary threshold.
    last5interval = zeros( 5, 1 );
    last5interval(:) = 0.75 * Fs;
    last5interval_average = sum( last5interval(:) ) / 5;
%     secondary_tminus = Tminus;
    % Modified end.
    i = idxWindow;
    Rpeakcnt = 1;
    while( i < Samplecnt - idxWindow )
        if( tECGs(i,j) > threshold && ( i - Tminus ) > ( 0.2 * Fs ) )
            % abs() for detecting Reverse rpeak.
%             [~,QRSloc] = max( abs( ECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j ) ) );
            [~,QRSloc] = max( ECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j ) );
            real_loc = i - 0.5*idxWindow + QRSloc - 1;
            if( real_loc - Tminus > ( 0.2 * Fs ) )
                RpeakIndex( Rpeakcnt,j ) = real_loc;
                Tminus = real_loc;
%                 RpeakIndex( Rpeakcnt,j ) = i - 0.5*idxWindow + QRSloc - 1;
%                 Tminus = i;
%                 threshArray(1) = [];
%                 threshArray(end+1) = max( tECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j) );
                threshArray(1:end-1) = threshArray( 2:end );
                threshArray( end ) = max( tECGs( i:( i + 0.5*idxWindow ), j ) );
                if Rpeakcnt > 7
                    vector1 = ( RpeakIndex(Rpeakcnt,j) - RpeakIndex(Rpeakcnt-6:Rpeakcnt,j) ) / Fs * lamda1;
                    vector2 = ( threshArray(:) - min(threshArray) ) * lamda2;
                    vector  = gaussian( sqrt( vector1.^2 + vector2.^2 ), lamda )';
                    % Old vector calculate model                    
%                     vector = gaussian( ( RpeakIndex(Rpeakcnt,j) - RpeakIndex(Rpeakcnt-6:Rpeakcnt,j) ) / Fs )';
                    threshold = threshFrac * ( vector * threshArray ) / sum(vector);
                end
                
                if( Rpeakcnt > 1)
                    last5interval( 1:4 ) = last5interval( 2:5 );
                    last5interval( end ) = max( 0.2 * Fs, RpeakIndex( Rpeakcnt,j ) - RpeakIndex( Rpeakcnt - 1,j ) );
                    last5interval_average = sum( last5interval ) / 5;
                end
                Rpeakcnt = Rpeakcnt + 1;
                i = ceil( Tminus + Fs * 0.2 );
            end
        elseif( Rpeakcnt > 1 & ( i - Tminus > 1.6 * last5interval_average ) )
            secondary_threshold = threshold * threshFrac2;
            iter = RpeakIndex( Rpeakcnt - 1,j ) + 0.2 * Fs;
            while( iter < i )

                if( tECGs( iter,j ) > secondary_threshold && ( iter - Tminus ) > 0.2 * Fs )
                    [~,QRSloc] = max( abs( ECGs( (iter-0.5*idxWindow):(iter+0.5*idxWindow), j ) ) );
                    real_loc = iter - 0.5*idxWindow + QRSloc - 1;
                    if( real_loc - Tminus > ( 0.2 * Fs ) )
                        RpeakIndex( Rpeakcnt,j ) = real_loc;
                        Tminus = real_loc;
                        threshArray(1:end-1) = threshArray( 2:end );
                        threshArray( end ) = max( tECGs( (iter - 0.5*idxWindow ):( iter + 0.5*idxWindow ), j ) );
                        if Rpeakcnt > 7
                            vector1 = ( RpeakIndex(Rpeakcnt,j) - RpeakIndex(Rpeakcnt-6:Rpeakcnt,j) ) / Fs * lamda1;
                            vector2 = ( threshArray(:) - min(threshArray) ) * lamda2;
                            vector  = gaussian( sqrt( vector1.^2 + vector2.^2 ), lamda )';
                            % Old vector calculate model                    
        %                     vector = gaussian( ( RpeakIndex(Rpeakcnt,j) - RpeakIndex(Rpeakcnt-6:Rpeakcnt,j) ) / Fs )';
                            threshold = threshFrac2 * ( vector * threshArray ) / sum(vector);
                        end
                        if( Rpeakcnt > 1)
                            last5interval( 1:4 ) = last5interval( 2:5 );
                            last5interval( end ) = RpeakIndex( Rpeakcnt,j ) - RpeakIndex( Rpeakcnt - 1,j );
                            last5interval_average = sum( last5interval ) / 5;
                        end
                        Rpeakcnt = Rpeakcnt + 1;
                        i = ceil( Tminus + 0.2 * Fs );
                        break;
                    end
                end
                iter = iter + 1;
            end
            Tminus = Tminus + 1.6 * last5interval_average - 0.2 * Fs;
        end
        i = i + 1;
    end
%     vector
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


