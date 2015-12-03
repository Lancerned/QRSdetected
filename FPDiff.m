function [ dSig ] = FPDiff( iSig )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title:     Five Point Differential.
%Programmer:    Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  11/15/2015
%Last Changed:  11/30/2015
%Changed By:    Pan Jiabin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


[ Samplecnt, Recordcnt ] = size( iSig );

dSig = zeros( Samplecnt, Recordcnt );

for j = 1:Recordcnt
    
    %Boundary conditions
    dSig(1,j) = ( iSig(3,j) + 2 * iSig(2,j) ) * ( 1.0 / 8.0 );
    dSig(2,j) = ( iSig(4,j) + 2 * ( iSig(3,j) - iSig(1,j) ) ) * ( 1.0 / 8.0 );
    dSig(end,j) = ( -iSig(end-2,j) + 2 * ( - iSig(end-1,j) ) ) * ( 1.0 / 8.0 );
    dSig(end-1,j) = ( -iSig(end-3,j) + 2 * ( iSig(end,j) - iSig(end-2,j) ) ) * ( 1.0 / 8.0 );
    
    %Loop for the differential
    for i = 3:Samplecnt-2
        dSig(i,j) = ( iSig(i+2,j) - iSig(i-2,j) + 2 * ( iSig(i+1,j) - iSig(i-1,j) ) ) * ( 1.0 / 8.0 );
    end
end

