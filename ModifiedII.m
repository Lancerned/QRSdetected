function [ RpeakIndex ] = ModifiedII( ECGs, Fs )
%UNTITLED4 Summary of this function goes here
%Data:          2015-11-16
%Description:   Modified Method Tompkins
%Include:       
%Last changed: 	2015-12-01
%Changed By:	Pan Jiabin
%

fprintf('ModifiedII started \n');
[ Samplecnt Recordcnt ] = size( ECGs );
idxWindow = ceil( Fs*0.1);
tECGs = FPDiff( ECGs );
tECGs = tECGs .* tECGs;

fprintf('FPDiff finished\n');

for j = 1:Recordcnt
    Tminus = -(0.1*Fs);     %Tminus：记录不应期
    Pastend = 1024;         %Pastend：记录分块阈值的终止点
    Rmsr = sum( tECGs( 1:1024 ) ) / 1024;       %Rmsr：当前模块的RMS值，初始化为第一个模块的RMS
    Regionmaxp = max( tECGs( 1:1+ 1023, j ) ); 
    %Regionmaxp：前一模块的区域极大值，初始化为第一模块的极大值
    Regionmaxr = 0;                             %Regionmaxr：记录当前模块的最大值
    threshold = 1.6 * Rmsr;     %threshold：初始化为1.6倍的RMS值
    i = 1;
    Rpeakcnt = 1;
    while( i < Samplecnt )
        if( i == Pastend && Pastend + 1024 <= Samplecnt )
            %阈值更新策略为，每到一个新模块则更新阈值
            Rmsr = sum( tECGs( j:j+1023 ) ) / 1024;
            Regionmaxr = max( tECGs( j:j+ 1023 ) );
            if( Rmsr > 0.18 * Regionmaxr && Regionmaxr <= 2 * Regionmaxp )
                threshold = 0.39 * Regionmaxr;
            else if(  Rmsr > 0.18 * Regionmaxr && Regionmaxr > 2 * Regionmaxp )
                    threshold = 0.39 * Regionmaxp;
                else 
                    threshold = 1.6 * Rmsr;
                end
            end
            Regionmaxp = Regionmaxr;
            Pastend = i + 1024;
        end
        if( i > idxWindow && i < Samplecnt - idxWindow )
            if( tECGs(i,j) > threshold && ( i - Tminus ) > ( 0.2 * Fs ) )
                [~,QRSloc] = max( abs( ECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j ) ) );
                RpeakIndex( Rpeakcnt,j ) = i - 0.5*idxWindow + QRSloc - 1;
                Rpeakcnt = Rpeakcnt + 1;
                Tminus = i;
            end
        end
        i = i + 1;
    end
end


end

