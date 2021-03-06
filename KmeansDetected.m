function [ Feature ] = KmeansDetected( Signal, Fs )
% function [ Rpeak ] = KmeansDetected( Signal, Fs )

% Title:                 K-means Detected method 
% Author:                Pan	Jiabin
% Originally Written:	2015/12/02
% Last changed:          2015/12/04
% Changed By:            Pan Jiabin

[~, LeadCnt] = size( Signal );


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
        
        Feature( LeadIter ) = getfeature( Signal( :,LeadIter ), Rpeak );
    end
end

        
    
end
		





