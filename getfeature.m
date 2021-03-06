function [ feature ] = getfeature( sig, Rpeak )
% Title: Get feature through the Rpeak
% Warning:  This funtion will return ECG feature except the first and the
%           last beat.
% Author:   Pan Jiabin
% Originally Written:   2015/12/04
% last Changed: 
% Changed By:

%% Search the Q and S 
% slope(i) equal to the signal( i+1 ) - signal( i ), one sample
%   delay
% Here size( Rpeak, 2 ) = 2 !!!!!
slope = sig( 2:end ) - sig( 1:end-1 );
slope = [slope(1); slope];
TempQDeep = zeros( length( Rpeak(:) ),1 );
TempSDeep = zeros( length( Rpeak(:) ),1 );

for iter = 1:length( Rpeak(:) )

    %Find the TempQDeep
    iter_slope = Rpeak( iter );
    edge = 0;
    if( iter ~= 1 )
        edge = Rpeak( iter - 1 );
    end
    while( iter_slope > edge )
        if( slope( iter_slope ) > 0 && slope( iter_slope - 1 ) < 0 )
            TempQDeep(iter) = iter_slope - 1;
            break;
        end
        iter_slope = iter_slope - 1;
    end
    if( iter_slope == edge )
        TempQDeep( iter ) = Rpeak( iter ) - floor( ( Rpeak(iter) - edge ) * 0.25 );
    end

    %Find the TempSDeep
    iter_slope = Rpeak( iter );
    edge = length(sig) - 5;
    if( iter ~= length( Rpeak(:) ) )
        edge = Rpeak( iter + 1 );
    end
    while( iter_slope < edge )
        if( slope( iter_slope ) < 0 && slope( iter_slope + 1 ) > 0 )
            TempSDeep(iter) = iter_slope;
            break;
        end
        iter_slope = iter_slope + 1;
    end
    if( iter_slope == edge )
        TempSDeep( iter ) = Rpeak( iter ) + floor( ( edge - Rpeak(iter) ) * 0.25 );
    end
end 

%Search The Real Q and S point through TempSDeep and TempQDeep
Q = zeros( length( Rpeak(:) ),1 );
S = zeros( length( Rpeak(:) ),1 );
for iter = 1:length( Rpeak(:) )

    %Find the Real Q point
    iter_slope = TempQDeep( iter );
    edge = 1;
    if( iter ~= 1 )
        edge = Rpeak( iter - 1 );
    end
    while( iter_slope > edge )
        if( slope( iter_slope ) < 0 && slope( iter_slope - 1 ) > 0 )
            Q(iter) = iter_slope - 1;
            break;
        end
        iter_slope = iter_slope - 1;
    end
    if( iter_slope == edge )
        Q( iter ) = Rpeak( iter ) - 5;
    end

    %Find the real S point
    iter_slope = TempSDeep( iter );
    edge = length( sig ) - 5;
    if( iter ~= length( Rpeak(:) ) )
        edge = Rpeak( iter + 1 );
    end
    while( iter_slope < edge )
        if( slope( iter_slope ) > 0 && slope( iter_slope + 1 ) < 0 )
            S(iter) = iter_slope;
            break;
        end
        iter_slope = iter_slope + 1;
    end
    if( iter_slope == edge )
        S( iter ) = Rpeak( iter ) + floor( ( edge - Rpeak(iter) ) * 0.25 );
    end
end
clear TempQDeep;
clear TempSDeep;

%% Now we search the  Ppeak and Tpeak postion
% Here is a funny thing
% We will get P and T points one less than the Rpeak counts.
% Ok, let's find the P and T peak first.

TP_border = zeros( length( Rpeak(:) ) - 1 , 2 );
TP_border( :,1 ) = S( 1:end-1 );
TP_border( :,2 ) = Q( 2:end );
Ppeak = zeros( length( Rpeak(:) ) - 1, 1 );
Tpeak = zeros( length( Rpeak(:) ) - 1, 1 );
for iter = 1:size( TP_border, 1 )
    edge_left   = TP_border( iter,1 ) + 1;
    edge_right  = TP_border( iter,2 );
    iter_slope  = edge_right;
    max_pos1   = edge_right - 5;
    max_pos2   = edge_left + 5;
    while( iter_slope > edge_left )
        if( slope( iter_slope ) < 0 && slope( iter_slope - 1 ) > 0 )
            if( sig(iter_slope-1) > sig( max_pos1 ) )
                max_pos2 = max_pos1;
                max_pos1 = iter_slope - 1;
            elseif( sig( iter_slope - 1 ) > sig( max_pos2 ) )
                max_pos2 = iter_slope - 1;
            end
        end
        iter_slope = iter_slope - 1;
    end
    if( max_pos1 < max_pos2 )
        Tpeak(iter) = max_pos1;
        Ppeak(iter) = max_pos2;
    else
        Tpeak(iter) = max_pos2;
        Ppeak(iter) = max_pos1;
    end
end

% Ppeak/Tpeak find Finished.
% Saved Tpeak/Rpeak  int Tpeak, Ppeak , total ( n - 1 ) counts
% Next step we will find the P/T front and rear.
Prear   = zeros( length( Rpeak(:) ) - 1, 1 );
Pfront  = zeros( length( Rpeak(:) ) - 1, 1 );
Trear   = zeros( length( Rpeak(:) ) - 1, 1 );  
Tfront  = zeros( length( Rpeak(:) ) - 1, 1 );

for iter = 1:length( Tpeak )

    TP_slope = ( sig( Ppeak(iter) ) - sig( Tpeak(iter) ) ) ... 
                / ( Ppeak(iter) - Tpeak(iter) );
    TP_slope = abs( TP_slope );

    % find Trear first.
    iter_slope = Tpeak(iter) + 1;
    edge = Ppeak(iter);         %Trear's right edge
    while( iter_slope < edge )
%                 if( iter_slope > -TP_slope )
        if( iter_slope > TP_slope )
            Trear(iter) = iter_slope;
            break;
        end
        iter_slope = iter_slope + 1;
    end
    if( iter_slope == edge )
        Trear(iter) = Tpeak(iter) + floor( abs( ( edge - Tpeak(iter) ) / 2 ) );
    end

    % find Tfront 
    iter_slope = Tpeak( iter ) - 2;
    edge = S(iter);
    while( iter_slope > edge )
%                 Trear(iter)
%                 iter_slope
%                 iter
        if( abs( sig( iter_slope ) - sig( Trear(iter) ) ) < 0.01 )
            Tfront(iter) = iter_slope;
            break;
        end
        iter_slope = iter_slope - 1;
    end
    if( iter_slope == edge )
        Tfront(iter) = edge + floor( abs( ( Tpeak(iter) - edge ) / 2 ) );
    end

    % Find Pfront and Prear
    % find Pfront
    iter_slope = Ppeak( iter ) - 1;
    edge = Tpeak( iter );
    while( iter_slope > edge )
        if( slope( iter_slope ) > TP_slope )
            Pfront(iter) = iter_slope;
            break;
        end
        iter_slope = iter_slope - 1;
    end
    if( iter_slope == edge )
        Pfront( iter ) = edge + floor( ( Ppeak(iter) - edge ) / 2 );
    end

    % find Prear
    iter_slope = Ppeak( iter ) + 2;
    edge = Q( iter + 1 );
    while( iter_slope < edge )
%                 Pfront(iter)
        if( abs ( sig( iter_slope ) - sig( Pfront(iter) ) ) < 0.01 )
            Prear(iter) = iter_slope;
            break;
        end
        iter_slope = iter_slope + 1;
    end
    if( iter_slope == edge )
        Prear( iter ) = Ppeak(iter) + floor( ( edge - Ppeak(iter) ) / 2 );
    end
end


    %% Definition a New cell "Feature" to store the ECG feature Info
% Feature = { Q, Rpeak, S, Pfront, Ppeak, Prear,
%               Tfront, Tpeak, Trear };
% For feature detected, wo store the ECG feature without the first
%           and the end ECG beat.
feature.Rpeak = Rpeak( 2:end-1 );
feature.Q   = Q( 2:end-1 );
feature.S   = S( 2:end-1 );
feature.Ppeak = Ppeak( 1:end-1 );
feature.Tpeak = Tpeak( 2:end );
feature.Pfront = Pfront( 1:end-1 );
feature.Prear = Prear( 1:end - 1 );
feature.Tfront = Tfront( 2:end );
feature.Trear = Trear( 2:end );

end

