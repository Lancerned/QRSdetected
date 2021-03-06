function [ RpeakIndex ] = KNNdetected( ECGs, Fs, para )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title: QRS Detected Algorithm From The Python
%Programmer:    Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  11/15/2015
%Last Changed:      03/07/2016
%Changed By:        Pan Jiabin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vector = [ 0.5412    0.5879    1.0260    2.2976    7.3288 ];

if nargin < 3
    threshFrac = vector(1);
    threshFrac2 = vector(2);
    lamda1 = vector(3);             % For time 
    lamda2 = vector(4);             % For peak
    lamda  = vector(5);
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
% tECGs = mwintegration( tECGs, idxWindow );
tECGs = mwintegration( tECGs );

for j = 1:Recordcnt
    Tminus = -(0.1*Fs);
    threshArray = zeros( 7, 1 );


    % Modified thresArray initial method.
    for i = 1:7
        init_segment = tECGs( (2*i - 1)*Fs:(2*i + 1 )*Fs, j );
        initMax = max( init_segment );
        threshArray(i) = initMax;
    end
    threshold = 0.4 * ( sum(threshArray) - min(threshArray) - max(threshArray) ) / 5;
    % Modified secondary threshold.
    last5interval = zeros( 5, 1 );
    last5interval(:) = 0.75 * Fs;
    last5interval_average = sum( last5interval(:) ) / 5;
%     secondary_tminus = Tminus;
    % Modified end.
    i = idxWindow;
    Rpeakcnt = 1;
    while( i < Samplecnt - 3 * idxWindow )
        if( tECGs(i,j) > threshold && ( i - Tminus ) > ( 0.2 * Fs ) )
            % abs() for detecting Reverse rpeak.
%             [~,QRSloc] = max( abs( ECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j ) ) );
            [ tmax, tmaxloc ] = max( tECGs( i + 1:( i + idxWindow ), j ) );
            tmaxloc = i + tmaxloc;
            [~,QRSloc] = max( ECGs( tmaxloc + 1:( tmaxloc + 2*idxWindow ), j ) );
            real_loc = tmaxloc + QRSloc;
            %检测不应期保护，防止重复定位到同一位置
            if ( Rpeakcnt > 1 ) & ( real_loc - RpeakIndex( Rpeakcnt - 1, j ) < 0.2 * Fs )
%                 Tminus = tmaxloc;
                i = i + 1;
                continue;
            end
            RpeakIndex( Rpeakcnt,j ) = real_loc;
            Tminus = tmaxloc;
            threshArray( 1:end-1 ) = threshArray( 2:end );
            threshArray( end ) = tmax;
            
            if Rpeakcnt > 6
                vector1 = ( RpeakIndex(Rpeakcnt,j) - RpeakIndex(Rpeakcnt-6:Rpeakcnt,j) ) / Fs * lamda1;
                vector2 = ( threshArray(:) - min(threshArray)  ) * lamda2;
                vector  = gaussian( sqrt( vector1.^2 + vector2.^2 ), lamda )';
%                 vector = gaussian( vector2, lamda )';
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
            
            %% Search back part
        elseif ( Rpeakcnt > 1 & ( i - Tminus > 1.5 * last5interval_average ) )
            secondary_threshold = threshold * threshFrac2;
%             iter = RpeakIndex( Rpeakcnt - 1, j );
            iter = tmaxloc + 0.1 * Fs;
            while( iter < i )
                if( tECGs( iter,j ) > secondary_threshold && ( iter - Tminus ) > 0.2 * Fs )
                    [ tmax, tmaxloc ] = max( tECGs( iter + 1:( i + idxWindow ), j ) );
                    tmaxloc = iter + tmaxloc;
                    [~,QRSloc] = max( ECGs( tmaxloc + 1:( tmaxloc + 2*idxWindow ), j ) );
                    real_loc = tmaxloc + QRSloc;
                    
                    % 不应期判别
                    if ( Rpeakcnt > 1 ) & ( real_loc - RpeakIndex( Rpeakcnt - 1, j ) < 0.2 * Fs )
%                         Tminus = tmaxloc;
                        iter = iter + 1;
                        continue;
                    end
                    
                    RpeakIndex( Rpeakcnt,j ) = real_loc;
                    Tminus = tmaxloc;
                    threshArray( 1:end-1 ) = threshArray( 2:end );
                    threshArray( end ) = tmax;
                    
                    if Rpeakcnt > 6
                        vector1 = ( RpeakIndex(Rpeakcnt,j) - RpeakIndex(Rpeakcnt-6:Rpeakcnt,j)  ) / Fs * lamda1;
                        vector2 = ( threshArray(:) - min(threshArray) ) * lamda2;
                        vector  = gaussian( sqrt( vector1.^2 + vector2.^2 ), lamda )';
%                         vector = gaussian( vector2, lamda )';
                        % Old vector calculate model                    
%                         vector = gaussian( ( RpeakIndex(Rpeakcnt,j) - RpeakIndex(Rpeakcnt-6:Rpeakcnt,j) ) / Fs )';
                        threshold = threshFrac * ( vector * threshArray ) / sum(vector);
                    end
                    
                    if( Rpeakcnt > 1)
                        last5interval( 1:4 ) = last5interval( 2:5 );
                        last5interval( end ) = max( 0.2 * Fs, RpeakIndex( Rpeakcnt,j ) - RpeakIndex( Rpeakcnt - 1,j ) );
                        last5interval_average = sum( last5interval ) / 5;
                    end
                    Rpeakcnt = Rpeakcnt + 1;
                    break;
                end
                iter = iter + 1;
            end
            % 设置不应期，防止不断地回溯
            if( iter == i )
                Tminus = i - 0.2 * Fs;
%                 threshold = secondary_threshold;
            end
            %% Search back end

        end
        i = i + 1;
    end
end

end



