%Title:                 K-means Detected method 
%Author:                Pan	Jiabin
%Originally Written:	2015/12/02
%Last changed:          2015/12/04
%Changed By:            Pan Jiabin

% function [ Rpeak ] = KmeansDetected( Signal, Fs )
function [ Feature ] = KmeansDetected( Signal, Fs )
[SampleCnt, LeadCnt] = size( Signal );


% slope = Signal(2:end,:) - Signal( 1:end-1,: );
% size( slope);

for LeadIter = 1:LeadCnt
    Rpeak = [];
    slope = Signal( 2:end,LeadIter ) - Signal( 1:end-1,LeadIter );
	kmeans_input = abs( slope );
    clear IDX;
    clear Cluster_center;
	[IDX, Cluster_center] = kmeans( kmeans_input, 2, 'emptyaction', 'drop' );
    Index1 = find( IDX == 1 );
    Index2 = find( IDX == 2 );
    lenIndex1 = length( Index1 );
    lenIndex2 = length( Index2 );
    QRSIndex = Index1;
    if( lenIndex1 > lenIndex2 )
        QRSIndex = Index2;
    end
	%extract the QRS target index -->> QRSIndex
	
	QRSCnt = 1;
	
	if( length( QRSIndex ) > 0 )

		QRSBorder( QRSCnt ).left = QRSIndex( 1 );
		QRSBorder( QRSCnt ).right = QRSBorder( QRSCnt ).left;
		% QRSCnt = QRSCnt + 1;
		% Note the QRS border.
		for Iter = 2:length( QRSIndex )

			if( QRSIndex(Iter) - QRSBorder( QRSCnt ).left > 0.3 * Fs )
				QRSBorder( QRSCnt ).right = QRSIndex( Iter - 1 );
				QRSCnt = QRSCnt + 1;
				QRSBorder( QRSCnt ).left = QRSIndex( Iter );
				QRSBorder( QRSCnt ).right = QRSBorder( QRSCnt ).left;
			end
        end
    

        for Iter = 1:length( QRSBorder )
            TempLeft = QRSBorder( Iter ).left;
            TempRight = QRSBorder( Iter ).right;
            [~,RelativePos] = max( Signal( TempLeft:TempRight ,LeadIter ) );
            Rpeak( Iter ) = TempLeft + RelativePos - 1;
        end
        clear QRSBorder;
        
        

        
        %% Search the Q and S 
        % slope(i) equal to the signal( i+1 ) - signal( i ), one sample
        %   delay
        % Here size( Rpeak, 2 ) = 2 !!!!!
        
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
            edge = SampleCnt - 5;
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
            edge = 0;
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
            edge = SampleCnt - 5;
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
                    if( Signal(iter_slope-1) > Signal( max_pos1 ) )
                        max_pos1 = iter_slope - 1;
                    elseif( Signal( iter_slope - 1 ) > Signal( max_pos2 ) )
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
            
            TP_slope = ( Signal( Ppeak(iter) ) - Signal( Tpeak(iter) ) ) ... 
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
                if( abs( Signal( iter_slope, LeadIter ) - Signal( Trear(iter), LeadIter ) ) < 0.01 )
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
                if( abs ( Signal( iter_slope, LeadIter ) - Signal( Pfront(iter), LeadIter ) ) < 0.01 )
                    Prear(iter) = iter_slope;
                    break;
                end
                iter_slope = iter_slope + 1;
            end
            if( iter_slope == edge )
                Prear( iter ) = Ppeak(iter) + floor( ( edge - Ppeak(iter) ) / 2 );
            end
        end
        
%         slope = slope( 2:end,: );            
    end
        %% Definition a New cell "Feature" to store the ECG feature Info
    % Feature = { Q, Rpeak, S, Pfront, Ppeak, Prear,
    %               Tfront, Tpeak, Trear };
    % For feature detected, wo store the ECG feature without the first
    %           and the end ECG beat.
    Feature( LeadIter ).Rpeak = Rpeak( 2:end-1 );
    Feature( LeadIter ).Q   = Q( 2:end-1 );
    Feature( LeadIter ).S   = S( 2:end-1 );
    Feature( LeadIter ).Ppeak = Ppeak( 1:end-1 );
    Feature( LeadIter ).Tpeak = Tpeak( 2:end );
    Feature( LeadIter ).Pfront = Pfront( 1:end-1 );
    Feature( LeadIter ).Prear = Prear( 1:end - 1 );
    Feature( LeadIter ).Tfront = Tfront( 2:end );
    Feature( LeadIter ).Trear = Trear( 2:end );
    
end
		





