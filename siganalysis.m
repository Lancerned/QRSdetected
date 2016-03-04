clear;
clc;
clf;

load('208.mat');
sig = sig( 60000:90000 );
fpdiff = FPDiff( sig );
tECGs = sig(2:end,:) - sig(1:end-1,:);
% tECGs = tECGs .* tECGs;
tECGs = abs( tECGs );
tECGs = mwintegration( tECGs );
max(tECGs)
% fpdiff = mwintegration( tECGs );

% rmss = rms(sig);
plot( sig );
hold on;
plot( tECGs, 'r' );
hold on;
plot( fpdiff, 'g' );

% PLot detected Rpeak position.
Rpeak = KNNdetected( sig, 360 );
for i = 1:length(Rpeak)
    hold on;
    plot( Rpeak(i), sig(Rpeak(i)), 'bo' );
end