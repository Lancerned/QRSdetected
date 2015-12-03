%This cript is just a fake version.
%Author:	Pan	Jiabin
%Originally Date:	2015/12/02
%

function [ Rpeak ] = KmeansDetected( Signal, Fs )

[~, LeadCnt] = size( Signal );


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
    end

end
end
		





