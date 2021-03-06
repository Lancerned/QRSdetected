%% ECG plot waves and atr data in the project
%  1st read the files for data. That is (*.dat) (*.hea) (*.atr).
%  2nd plot the data by (*.dat) and (*.atr).
%  3rd denosie the ECG waves. That is Function filter() and wavelet.
%  4th detect the QRS waves and pos. That is Function diff()
%  5th calc the decte rate by R pos.
%  Modified Last 2015.10.27
%-------------------------------------------------------------------------
clc; clear all;


%% Load ECG MIT-BIH Data
%------ SPECIFY DATA ------------------------------------------------------
%------ 指定数据文件 -------------------------------------------------------
PATH= 'E:\FinalUMIPECGAnalysisCode-2013\Test'; % 指定数据的储存路径
HEADERFILE= '201.hea';      % .hea 格式，头文件，可用记事本打开
ATRFILE= '201.atr';         % .atr 格式，属性文件，数据格式为二进制数
DATAFILE='201.dat';         % .dat 格式，ECG 数据
SAMPLES2READ=3600;          % 指定需要读入的样本数 
                            % 若.dat文件中存储有两个通道的信号:
                            % 则读入 2*SAMPLES2READ 个数据 
                            % 3600 samples are 10 seconds 360Hz * 10s =3600

%% Read Data Header Files                           
%------ LOAD HEADER DATA --------------------------------------------------
%------ 读入头文件数据 -----------------------------------------------------
%
% 示例：用记事本打开的100.hea 文件的数据
%
%        100 2 360 650000
%        100.dat 100 100 11 1024 995 -22131 0 MLII
%        100.dat 100 100 11 1024 1011 20052 0 V5
%        # 69 M 1085 1629 x1
%        # Aldomet, Inderal
%
%-------------------------------------------------------------------------
fprintf(1,'读取头文件：%s.\n', HEADERFILE); % 在Matlab命令行窗口提示当前工作状态
% 
% 【注】函数 fprintf 的功能将格式化的数据写入到指定文件中。
% 表达式：count = fprintf(fid,format,A,...)
% 在字符串'format'的控制下，将矩阵A的实数数据进行格式化，并写入到文件对象fid中。该函数返回所写入数据的字节数 count。
% fid 是通过函数 fopen 获得的整型文件标识符。fid=1，表示标准输出（即输出到屏幕显示）；fid=2，表示标准偏差。
%
signalhea= fullfile(PATH, HEADERFILE);    % 通过函数 fullfile 获得头文件的完整路径
fid1=fopen(signalhea,'r');                % 打开头文件，其标识符为 fid1 ，属性为'r'--“只读”
z= fgetl(fid1);                           % 读取头文件的第一行数据，字符串格式
A= sscanf(z, '%*s %d %d %d',[1,3]);       % 按照格式 '%*s %d %d %d' 转换数据并存入矩阵 A 中
nosig= A(1);    % 信号通道数目
sfreq=A(2);     % 数据采样频率
clear A;        % 清空矩阵 A ，准备获取下一行数据
for k=1:nosig   % 读取每个通道信号的数据信息
    z= fgetl(fid1);
    A= sscanf(z, '%*s %d %d %d %d %d',[1,5]);
    dformat(k)= A(1);           % 信号格式; 这里只允许为 100 格式
    gain(k)= A(2);              % 每 mV 包含的整数个数
    bitres(k)= A(3);            % 采样精度（位分辨率）
    zerovalue(k)= A(4);         % ECG 信号零点相应的整数值
    firstvalue(k)= A(5);        % 信号的第一个整数值 (用于偏差测试)
end;
fclose(fid1);
clear A;

%% Read Data Binary Files
%------ LOAD BINARY DATA --------------------------------------------------
%------ 读取 ECG 信号二值数据 ----------------------------------------------
%
fprintf(1,'读数据文件：%s.\n', DATAFILE); % 在Matlab命令行窗口提示当前工作状态
if dformat~= [212,212], error('this script does not apply binary formats different to 212.'); end;
signald= fullfile(PATH, DATAFILE);            % 读入 100 格式的 ECG 信号数据
fid2=fopen(signald,'r');
A= fread(fid2, [3, SAMPLES2READ], 'uint8')';  % matrix with 3 rows, each 8 bits long, = 2*12bit
fclose(fid2);
% 通过一系列的移位（bitshift）、位与（bitand）运算，将信号由二值数据转换为十进制数
M2H= bitshift(A(:,2), -4);        %字节向右移四位，即取字节的高四位
M1H= bitand(A(:,2), 15);          %取字节的低四位
PRL=bitshift(bitand(A(:,2),8),9);     % sign-bit   取出字节低四位中最高位，向右移九位
PRR=bitshift(bitand(A(:,2),128),5);   % sign-bit   取出字节高四位中最高位，向右移五位
M( : , 1)= bitshift(M1H,8)+ A(:,1)-PRL;
M( : , 2)= bitshift(M2H,8)+ A(:,3)-PRR;
if M(1,:) ~= firstvalue, error('inconsistency in the first bit values'); end;
switch nosig
case 2
    M( : , 1)= (M( : , 1)- zerovalue(1))/gain(1);
    M( : , 2)= (M( : , 2)- zerovalue(2))/gain(2);
    TIME=(0:(SAMPLES2READ-1))/sfreq;
case 1
    M( : , 1)= (M( : , 1)- zerovalue(1));
    M( : , 2)= (M( : , 2)- zerovalue(1));
    M=M';
    M(1)=[];
    sM=size(M);
    sM=sM(2)+1;
    M(sM)=0;
    M=M';
    M=M/gain(1);
    TIME=(0:2*(SAMPLES2READ)-1)/sfreq;
otherwise  % this case did not appear up to now!
    % here M has to be sorted!!!
    disp('Sorting algorithm for more than 2 signals not programmed yet!');
end;
clear A M1H M2H PRR PRL;
% That is ECG Data is 2-Lead
% M( : , 1) is lead 1 data
% M( : , 2) is lead 2 data

%% Read Data Attributes Files
%------ LOAD ATTRIBUTES DATA ----------------------------------------------
%------ 读取 ECG 注释文件数据 ----------------------------------------------
%
fprintf(1,'读注释文件：%s.\n', ATRFILE); % 在Matlab命令行窗口提示当前工作状态
atrd= fullfile(PATH, ATRFILE);      % attribute file with annotation data
fid3=fopen(atrd,'r');
A= fread(fid3, [2, inf], 'uint8')';
fclose(fid3);
ATRTIME=[];
ANNOT=[];
sa=size(A);
saa=sa(1);
i=1;
while i<=saa
    annoth=bitshift(A(i,2),-2);
    if annoth==59
        ANNOT=[ANNOT;bitshift(A(i+3,2),-2)];
        ATRTIME=[ATRTIME;A(i+2,1)+bitshift(A(i+2,2),8)+...
                bitshift(A(i+1,1),16)+bitshift(A(i+1,2),24)];
        i=i+3;
    elseif annoth==60
        % nothing to do!
    elseif annoth==61
        % nothing to do!
    elseif annoth==62
        % nothing to do!
    elseif annoth==63
        hilfe=bitshift(bitand(A(i,2),3),8)+A(i,1);
        hilfe=hilfe+mod(hilfe,2);
        i=i+hilfe/2;
    else
        ATRTIME=[ATRTIME;bitshift(bitand(A(i,2),3),8)+A(i,1)];
        ANNOT=[ANNOT;bitshift(A(i,2),-2)];
   end;
   i=i+1;
end;
ANNOT(length(ANNOT))=[];       % last line = EOF (=0)
ATRTIME(length(ATRTIME))=[];   % last line = EOF
clear A;
ATRTIME= (cumsum(ATRTIME))/sfreq;
ind= find(ATRTIME <= TIME(end));
ATRTIMED= ATRTIME(ind);
ANNOT=round(ANNOT);
ANNOTD= ANNOT(ind);

%--------------%
%-2015.11.10-%
ANNOTDD = unique(ANNOT);
ANNOTDDD = zeros(1,length(ANNOTDD));
for i=1:length(ANNOT)
    for q=1:length(ANNOTDD)
        if ( ANNOT(i) == ANNOTDD(q))
            ANNOTDDD(q) = ANNOTDDD(q)+1;
            break;
        end
    end
end
%-2015.11.10-%
%--------------%
fprintf(1,'读取心电信号文件完成\n');

%%
%------ DENOISE DATA ------------------------------------------------------
%------ 对心电数据去噪 -----------------------------------------------------
%
fprintf(1,'对心电数据进行预处理\n');
% 带通滤波器 filter()
%LPF
L( : , 1) = filter([1 0 0 0 0 0 -2 0 0 0 0 0 1],[1 -2 1],M(:,1))/24;

%HPF
H( : , 1) = filter([-1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 32 -32 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1],[1 -1],L(:,1))/24;

%Filter Delay
MN( : , 1) = H((22:end),1);

for k=1:22
    MN(3578+k) = 0;
end

%Wavelet transform
hold on;
[c,l]=wavedec(MN(:,1),8,'sym8');   % 选取sym8小波对信号做8层分解
    cA8=appcoef(c,l,'sym8',8);
    cD8=detcoef(c,l,8);
    cD7=detcoef(c,l,7);
    cD6=detcoef(c,l,6);
    cD5=detcoef(c,l,5);
    cD4=detcoef(c,l,4);
    cD3=detcoef(c,l,3);
    cD2=detcoef(c,l,2);
    cD1=detcoef(c,l,1);
    % 将cA8，cD1，cD2，cD3过滤（即置零）
    cA8(:,1)=0;
    cD1(:,1)=0;
    cD2(:,1)=0;
    cD3(:,1)=0;
    re_c=[cA8;cD8;cD7;cD6;cD5;cD4;cD3;cD2;cD1];
    MN(:,1)=waverec(re_c,l,'sym8'); %重构
    
%  that M( : ,1) is ECG data after denosing

%% Plot figure 1

    figure(1); clf, box on, hold on
    subplot(411);
    plot(TIME, M(:,1),'r');
    string=['心电信号原始数据 '];
    title(string);
    
    subplot(412);
    plot(TIME, L(:,1),'k');
    string=['第一次将原始信号通过低通滤波去噪数据 '];
    title(string);
    
    subplot(413);
    plot(TIME, H(:,1),'B');
    string=['第二次在低通滤波处理高通滤波去噪数据 '];
    title(string);
    
    subplot(414);
    plot(TIME, MN(:,1),'r');
    string=['第三次在滤波器处理后小波变换最终数据 '];
    title(string);

%% Plot figure 2

    % MN经过一系列去噪后心电数据
    M(:,1) = MN(:,1);

    figure(8); clf, box on, hold on
    subplot(411);
    plot(TIME, M(:,1),'r');
    string=['去噪后心电信号数据 ',DATAFILE,' 导联No.1'];
    title(string);

    hold on;
    for k=1:length(ATRTIMED)
        text(ATRTIMED(k),0,num2str(ANNOTD(k)));
        hold on;
    end;

    fprintf(1,'显示心电数据波形完成\n');

%% 差分方程 边界条件

    D(1) = (1.0/8.0) * ( (-(2.0*0)) + (2.0*M(2,1)) +M(3,1));
    
    D(2) = (1.0/8.0) * ( (-(2.0*M(1,1))) + (2.0*M(3,1)) +M(4,1));
    
    D(length(M)-1) = (1.0/8.0) * ( (-(M(length(M)-3,1))) + (-2.0*M(length(M)-2,1)) +2.0*M(length(M)-1,1));
    
    D(length(M)) = (1.0/8.0) * ( (-(M(length(M)-2,1))) + (-2.0*M(length(M)-1,1)));
    
    %Loop 
    
    for i=1:length(M)
        
        if (i > 2) && (i < length(M)-1) 
            D(i) = ( (1.0/8.0) * ( (-M(i-2,1)) + (-2.0*M(i-1,1)) + (2.0*M(i+1,1)) + M(i+2,1)));
        end
        
    end

    subplot(412);
    plot(TIME, D(1,:),'b');
    title('第一导联边界条件差分');
    fprintf(1,'完成边界条件差分计算\n');

%% 平方运算

    S(1,:) = D(1,:).*D(1,:);
    subplot(413);
    plot(TIME, S(1,:),'r');
    title('第一导联计算差分平方');
    fprintf(1,'完成差分平方数值计算\n');  
    
%% 计算移动窗积分

  WINDOW = 100;
  for i=WINDOW+1 : length(M)
      ECGArrayTemp(i) = 0;
      for j=1:WINDOW
         if(i-j>=1) 
             WindowArray(j) = S(1,i-j);
         else
             WindowArray(j) = 0;
         end
      ECGArrayTemp(i) = ECGArrayTemp(i) + WindowArray(j);
      end
  end
  
  W = S;
  for k = WINDOW+1 : length(M)
      W(1,k) = ECGArrayTemp(k);
  end
        subplot(414);
        plot(TIME, W(1,:),'k');
        title('第一导联计算移动窗体');

    fprintf(1,'完成对移动窗积分计算\n');  


%% 决策规则识别R

    idxWindow = 0.1 * sfreq;
    Tminus = -(0.1 * sfreq);
    threshFrac = 0.5;
    T = W(1, 3*sfreq:6*sfreq);
    initMax = max(W(1, 3*sfreq:6*sfreq));
    threshArray = [initMax,initMax,initMax,initMax,initMax,initMax,initMax];
    threshAverage = threshFrac*(initMax*7)/7;
    i = 1;
    QRSs = zeros(1,length(M));
    while ( i <= length(M) )
        i = i+1;
        if (i>idxWindow) && (i< (length(M) - idxWindow))
            if ( W(1,i) > threshAverage ) && ( (i - Tminus) > (0.4 * sfreq) )   % 0.2 is old
                QRSloc = abs( M(i-(0.5*idxWindow) : i+(0.5*idxWindow),1) );  % old is wrong mo W
                [Max,Pos] = max(QRSloc);
                QRSs(1,i-0.5*idxWindow+Pos) = M(i-0.5*idxWindow+Pos,1);
                Tminus = i;
                threshArray(1) = [];
                threshArray(7) = max( W(1, i-idxWindow : i+idxWindow) );
                threshAverage = threshFrac * (sum(threshArray) - (min(threshArray) + max(threshArray))) / 5;
            end
        end
    end

  figure(2); clf, box on, hold on

  plot(TIME, M(:,1),'r');
  hold on;
  plot(TIME(1:length(QRSs)), QRSs(1,:),'b');
  hold on;
for k=1:length(ATRTIMED)
    text(ATRTIMED(k),0,num2str(ANNOTD(k)));
    hold on;
end;

  title('R波识别');
 
%% 决策规则识别T波

    TRegions = M(:,1);
    TFlags = zeros(length(M),1);
    TWavs = zeros(length(M),1);
    
    idxWindow = 0.1*sfreq;
    
%   QRSs(find(QRSs == 0)) = [];
%   get pos where is not 0;
    k=1;
    
    for j=1:length(QRSs)
        if( QRSs(j))
            beat_times(k) = j;
            ramp(k) = QRSs(j);
            k = k+1;
        end
    end   
    
    %Detect QRS regions
    for k=1:length(beat_times)
        for i=1:round(1.5*idxWindow)
                TFlags(beat_times(k) + 3*idxWindow + i) = 1;
        end 
    end

   
    
%     %Detect QRS regions
%     for k=1:length(beat_times)
%         for i=1:round(1.5*idxWindow)
%             TFlags(beat_times(k) + 3*idxWindow + i) = 1;
%         end 
%     end

    % differential D(1,:)
    
    D_T = D;
    
    figure(3); clf, box on, hold on
    subplot(411);
    plot(TIME, D_T(1,:),'r');
    title('心电信号计算边界条件差分');
    
    % remove QRS regions
    for i=1:length(M)
        if (TFlags(i) == 0)
            D_T(1,i) = 0;
            TRegions(i) = 0;
        end
    end
    
    subplot(412);
    plot(TIME, D_T(1,:),'k');
    title('心电信号去除QRS波形');
    
    % 平方运算
    S_T(1,:) = D_T(1,:).*D_T(1,:);
    subplot(413);
    plot(TIME, S_T(1,:),'b');
    title('去除QRS计算差分平方');
% fprintf(1,'完成差分平方数值计算\n');

    % 计算移动窗积分
  for i=WINDOW+1 : length(M)
      ECGArrayTemp_T(i) = 0;
      for j=1:WINDOW
         if(i-j>=1) 
             WindowArray_T(j) = S_T(1,i-j);
         else
             WindowArray_T(j) = 0;
         end
      ECGArrayTemp_T(i) = ECGArrayTemp_T(i) + WindowArray_T(j);
      end
  end
  
  W_T = S_T;
  for k = WINDOW+1 : length(M)
      W_T(1,k) = ECGArrayTemp_T(k);
  end
    %plot
        subplot(414);
        plot(TIME, W_T(1,:),'k');
        title('T波计算移动窗体');    
    %
  
    %决策规则
%    idxWindow = 0.1 * sfreq;
    Tminus = -(0.1 * sfreq);
    threshFrac = 0.3;
    initMax = max(W_T(1, 3*sfreq:6*sfreq));
    threshArray = [initMax,initMax,initMax,initMax,initMax,initMax,initMax];
    threshAverage = threshFrac*(initMax*7)/7;
    for i =1:length(M)
        if (i>beat_times(1)) && (i< (length(M) - idxWindow))
            if ( W_T(1,i) > threshAverage ) && ( (i - Tminus) > (0.6 * sfreq) )
                TWavloc = abs( TRegions(i-(0.5*idxWindow) : i+(0.5*idxWindow),1) );
                [Max,Pos] = max(TWavloc);
                TWavs(i-0.5*idxWindow+Pos,1) = TRegions(i-0.5*idxWindow+Pos,1); 
                Tminus = i;
                threshArray(1) = [];
                threshArray(7) = max( W_T(1, i-idxWindow : i+idxWindow) );
                threshAverage = threshFrac * (sum(threshArray) - (min(threshArray) + max(threshArray))) / 5;
            end
        end
    end
    
  figure(4); clf, box on, hold on

  plot(TIME, M(:,1),'r');
  hold on;
  plot(TIME(1:length(TWavs)), TWavs(:,1),'b');
  title('T波识别');

%% 决策规则识别P波


    PRegions = M(:,1);
    PFlags = zeros(length(M),1);
    PWavs = zeros(length(M),1);
    
    idxWindow = 0.1*sfreq;
    
%     QRSs(find(QRSs == 0)) = [];
    % get pos where is not 0;
    k=1;
    for j=1:length(QRSs)
        if( QRSs(j))
            beat_times(k) = j;
            k = k+1;
        end
    end
    
    %Detect QRS regions
    for k=2:length(beat_times)   % old is k=1
        for i=1:round(1.5*idxWindow)
            PFlags(beat_times(k) - 2.5*idxWindow + i) = 1;
        end 
    end

    % differential D(1,:)
    
    D_P = D;
    
    figure(5); clf, box on, hold on
    subplot(411);
    plot(TIME, D_P(1,:),'r');
    title('心电信号计算边界条件差分');
    
    % remove QRS regions
    for i=1:length(M)
        if (PFlags(i) == 0)
            D_P(1,i) = 0;
            PRegions(i) = 0;
        end
    end
    
    subplot(412);
    plot(TIME, D_P(1,:),'k');
    title('心电信号去除QRS波形');
    
    % 平方运算
    S_P(1,:) = D_P(1,:).*D_P(1,:);
    subplot(413);
    plot(TIME, S_P(1,:),'b');
    title('去除QRS计算差分平方');
% fprintf(1,'完成差分平方数值计算\n');

    % 计算移动窗积分
  for i=WINDOW+1 : length(M)
      ECGArrayTemp_P(i) = 0;
      for j=1:WINDOW
         if(i-j>=1) 
             WindowArray_P(j) = S_P(1,i-j);
         else
             WindowArray_P(j) = 0;
         end
      ECGArrayTemp_P(i) = ECGArrayTemp_P(i) + WindowArray_P(j);
      end
  end
  
  W_P = S_P;
  for k = WINDOW+1 : length(M)
      W_P(1,k) = ECGArrayTemp_P(k);
  end
    %plot
        subplot(414);
        plot(TIME, W_P(1,:),'k');
        title('P波计算移动窗体');    
    %
  
    %决策规则
%   idxWindow = 0.1 * sfreq;
    Tminus = -(0.1 * sfreq);
    threshFrac = 0.1;
    initMax = max(W_P(1, 3*sfreq:6*sfreq));
    threshArray = [initMax,initMax,initMax,initMax,initMax,initMax,initMax];
    threshAverage = threshFrac*(initMax*7)/7;
    i = 1;
    k=1;
    for i =1:length(M)
        if (i>idxWindow) && (i< (length(M) - idxWindow))
            if ( W_P(1,i) > threshAverage ) && ( (i - Tminus) > (0.6 * sfreq) )
                PWavloc = abs( PRegions(i-(0.5*idxWindow) : i+(0.5*idxWindow),1) );
                [Max,Pos] = max(PWavloc);
                r_max(k) = Max;
                r_pos(k) = Pos;
                k = k+1;
                PWavs(i-0.5*idxWindow+Pos,1) = PRegions(i-0.5*idxWindow+Pos,1); 
                Tminus = i;
                threshArray(1) = [];
                threshArray(7) = max( W_P(1, i-idxWindow : i+idxWindow) );
                threshAverage = threshFrac * (sum(threshArray) - (min(threshArray) + max(threshArray))) / 5;
            end
        end
    end
    
  figure(6); clf, box on, hold on

  plot(TIME, M(:,1),'r');
  hold on;
  plot(TIME(1:length(PWavs)), PWavs(:,1),'k');
  title('P波识别');

  
  %%
  figure(7); clf, box on, hold on
  plot(TIME, M(:,1),'r');
  hold on;
  for k=1:length(ATRTIMED)
        text(ATRTIMED(k),0,num2str(ANNOTD(k)));
        hold on;
  end;
  hold on;
  plot(TIME(1:length(PWavs)), PWavs(:,1),'b');
  hold on;
  plot(TIME(1:length(TWavs)), TWavs(:,1),'k');
  hold on;
  plot(TIME(1:length(QRSs)), QRSs(1,:),'g');
    
  title('QRSPT波识别'); 


fprintf(1,'完成决策规则识别波形\n');
%% ---------------------------------------------------------------
fprintf(1,'心电信号工作全部完成\n');
%%