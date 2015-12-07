function [ RpeakIndex ] = ModifiedII( ECGs, Fs )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Title: Modified Method II For QRS detection
%Programmer:    Pan Jiabin
%Purpose:
%Primary User:
%Original Written:  11/16/2015
%Last Changed:  11/30/2015
%Changed By:    Pan Jiabin
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[ Samplecnt, Recordcnt ] = size( ECGs );
idxWindow = ceil( Fs*0.1);
tECGs = FPDiff( ECGs );
tECGs = tECGs .* tECGs;

for j = 1:Recordcnt
    Tminus = -(0.1*Fs);     %Tminus����¼��Ӧ��
    Pastend = 1024;         %Pastend����¼�ֿ���ֵ����ֹ��
    Rmsr = sqrt( sum( tECGs( 1:1024 ) ) / 1024 );       %Rmsr����ǰģ���RMSֵ����ʼ��Ϊ��һ��ģ���RMS
    Regionmaxr = max( tECGs( 1:1024, j ) ); 
    %Regionmaxp��ǰһģ������򼫴�ֵ����ʼ��Ϊ��һģ��ļ���ֵ
    Regionmaxp = Regionmaxr;                             %Regionmaxr����¼��ǰģ������ֵ
    threshold = 1.6 * Rmsr;     %threshold����ʼ��Ϊ1.6����RMSֵ
    i = 1;
    Rpeakcnt = 1;
    while( i < Samplecnt )
        if( i == Pastend && Pastend + 1024 <= Samplecnt )
            %��ֵ���²���Ϊ��ÿ��һ����ģ���������ֵ
            Rmsr = sqrt( sum( tECGs( i:i+1023 ) ) / 1024 );
            Regionmaxr = max( tECGs( i:i+ 1023 ) );
            if( Rmsr > 0.18 * Regionmaxr && Regionmaxr <= 2 * Regionmaxp )
                threshold = 0.39 * Regionmaxr;
            else if(  Rmsr > 0.18 * Regionmaxr && Regionmaxr > 2 * Regionmaxp )
                    threshold = 0.39 * Regionmaxp;
                else 
                    threshold = 1.6 * Rmsr;
                end
            end
            thresfrac = 0.4;
            threshold = threshold * thresfrac;
            Regionmaxp = Regionmaxr;
            Pastend = i + 1024;
        end
        if( i > idxWindow && i < Samplecnt - idxWindow )
            if( tECGs(i,j) > threshold && ( i - Tminus ) > ( 0.2 * Fs ) )
                [~,QRSloc] = max( ECGs( (i-0.5*idxWindow):(i+0.5*idxWindow), j ) );
                RpeakIndex( Rpeakcnt,j ) = i - 0.5*idxWindow + QRSloc - 1;
                Rpeakcnt = Rpeakcnt + 1;
                Tminus = i;
            end
        end
        i = i + 1;
    end
end


end

