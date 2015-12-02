function [ dSig ] = FPDiff( iSig )
%Five Point Differential.
%   Detailed explanation goes here
[ Samplecnt Recordcnt ] = size( iSig );
dSig = zeros( Samplecnt, Recordcnt );

for j = 1:Recordcnt
    %Boundary conditions
    dSig(1,j) = ( iSig(3,j) + 2 * iSig(2,j) ) * ( 1.0 / 8.0 );
    dSig(2,j) = ( iSig(4,j) + 2 * ( iSig(3,j) - iSig(1,j) ) ) * ( 1.0 / 8.0 );
    dSig(end,j) = ( -iSig(end-2,j) + 2 * ( - iSig(end-1,j) ) ) * ( 1.0 / 8.0 );
    dSig(end-1,j) = ( -iSig(end-3,j) + 2 * ( iSig(end,j) - iSig(end-2,j) ) ) * ( 1.0 / 8.0 );
    
    %%Loop for the differential
    %for i = 3:Samplecnt-2
    %    dSig(i,j) = ( iSig(i+2,j) - iSig(i-2,j) + 2 * ( iSig(i+1,j) - iSig(i-1,j) ) ) * ( 1.0 / 8.0 );
    %end

	dSig( 3:Samplecnt-2, j ) = ( iSig( 5:Samplecnt, j ) - iSig( 1:Samplecnt-4, j ) + ...
		2 * ( iSig( 4:Samplecnt-1, j ) - iSig( 2:Samplecnt-3, j) ) ) * ( 1.0 / 8.0 );
end
