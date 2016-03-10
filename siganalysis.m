clear;
clc;
clf;
Fs = 360;

load('208.mat');
% sig = signal;
head = 1;
trail = length( sig );

sig = sig( head:trail );
fpdiff = FPDiff( sig );
tECGs = sig(2:end,:) - sig(1:end-1,:);
% tECGs = tECGs .* tECGs;
tECGs = abs( tECGs );
tECGs = mwintegration( tECGs, 54 );
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
% for i = 1:length(Rpeak)
%     hold on;
%     plot( Rpeak(i), sig(Rpeak(i)), 'bo' );
% end

% Load and Plot Atr information
load( '108atr.mat' );
atr = atr( find( atr > head & atr < trail ) );
atr = atr(:) - head;
% for i = 1:length( atr )
%     hold on;
%     text( atr( i ), sig( atr(i),1 ), 'TP' );
% end


TP = 0;
FP = 0;
FN = 0;
iterRpeak = 1;
iterAtr = 1;
cntRpeak = length( Rpeak );
cntAtr = length( atr );
% 
% while( ( iterRpeak < cntRpeak ) & ( iterAtr < cntAtr ) )
%     if( abs( Rpeak( iterRpeak ) - atr( iterAtr ) ) < 0.15 *  Fs ) 
% %         text( Rpeak( iterRpeak ), sig( Rpeak(iterRpeak),1 ), 'TP' );
% %         hold on;
%         TP = TP + 1;
%         iterRpeak = iterRpeak + 1;
%         iterAtr = iterAtr + 1;
%     elseif( Rpeak( iterRpeak ) < atr( iterAtr ) )
%         text( Rpeak( iterRpeak ), sig( Rpeak(iterRpeak),1 ), 'FP' );
%         hold on;
%         FP = FP + 1;
%         iterRpeak = iterRpeak + 1;
%     else
%         text( atr( iterAtr ), sig( atr(iterAtr),1 ), 'FN' );
%         FN = FN + 1;
%         iterAtr = iterAtr + 1;
%     end
% end
% 

