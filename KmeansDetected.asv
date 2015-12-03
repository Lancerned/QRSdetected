%Title:                 K-means Detected method 
%Author:                Pan	Jiabin
%Originally Written:	2015/12/02
%Last changed:          2015/12/03
%Changed By:            Pan Jiabin

function [ Rpeak ] = KmeansDetected( Signal, Fs )

[SampleCnt, LeadCnt] = size( Signal );


slope = Signal(2:end,:) - Signal( 1:end-1,: );
size( slope);

for LeadIter = 1:LeadCnt
	
	[IDX, Cluster_center] = kmeans( abs( slope(:,LeadIter) ), 2, 'emptyaction', 'drop' );
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
	Rpeak = [];
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
            Rpeak( Iter,LeadIter ) = TempLeft + RelativePos - 1;
        end
        clear QRSBorder;
        
        
        %% Definition a New cell "Feature" to store the ECG feature Info
        % Feature = { Q, Rpeak, S, Pfront, Ppeak, Prear,
        %               Tfront, Tpeak, Trear };
        % For feature detected, wo store the ECG feature without the first
        %           and the end ECG beat.
        Feature( LeadIter ).Rpeak = Rpeak( 2:end-1 );
        
        %% Search the Q and S 
        % slope(i) equal to the signal( i+1 ) - signal( i ), one sample
        %   delay
        
        slope = [slope(1); slope(:)];
        TempQDeep = zeros( length( Rpeak ),1 );
        TempSDeep = zeros( length( Rpeak ),1 );
        
        for iter = 1:length( Rpeak )
            
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
            if( iter ~= length( Rpeak ) )
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
        Q = zeros( length( Rpeak ),1 );
        S = zeros( length( Rpeak ),1 );
        for iter = 1:length( Rpeak )
            
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
            if( iter ~= length( Rpeak ) )
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
        
        TP_border = zeros( length( Rpeak ) - 1 , 2 );
        TP_border( :,1 ) = S( 1:end-1 );
        TP_border( :,2 ) = Q( 2:end );
        Ppeak = zeros( length( Rpeak ) - 1, 1 );
        Tpeak = zeros( length( Rpeak ) - 1, 1 );
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
        % Next step we will find the P/T front and rear.
        Prear   = zeros( length( Rpeak ) - 1, 1 );
        Pfront  = zeros( length( Rpeak ) - 1, 1 );
        Trear   = zeros( length( Rpeak ) - 1, 1 );  
        Tfront  = zeros( length( Rpeak ) - 1, 1 );
        
        for iter = 1:length( Tpeak )
            
            TP_slope = Signal( Ppeak(iter) ) - Signal( Tpeak(iter) ) ) ... 
                        / ( Ppeak(iter) - Tpeak(iter) );
            % find Trear
    end
end
		





