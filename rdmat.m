function varargout=rdmat(varargin)
%
% [tm,signal,Fs,siginfo]=rdmat(recordName)
%
% Import a signal in physical units from a *.mat file generated by WFDB2MAT.
% Required Parameters:
%
% recorName
%       String specifying the name of the *.mat file.
%
% Outputs are:
%
% tm
%       A Nx1 array of doubles specifying the time in seconds.
% signal
%       A NxM matrix of doubles contain the signals in physical units.
% Fs
%       A 1x1 integer specifying the sampling frequency in Hz for the entire record.
%siginfo
%       A LxN cell array specifying the signal siginfo. Currently it is a
%       structure with the following fields:
%       
%        siginfo.Units
%        siginfo.Baseline
%        siginfo.Gain
%        siginfo.Description
%
% NOTE:
%       You can use the WFDB2MAT command in order to convert the record data into a *.mat file,
%       which can then be loaded into MATLAB/Octave's workspace using the LOAD command.
%       This sequence of procedures is quicker (by several orders of magnitude) than calling RDSAMP.
%       The LOAD command will load the signal data in raw units, use RDMAT to load the signal in physical units.
%
% KNOWN LIMITATIONS:
%       This function currently does support several of the features described 
%       in the WFDB record format (such as multiresolution signals) :
%          http://www.physionet.org/physiotools/wag/header-5.htm
%       If you are not sure that the record (or database format) you are reading is
%       supported, you can do an integrity check by comparing the output with RDSAMP:
%
%       [tm,signal,Fs,siginfo]=rdmat('200m');
%       [tm2,signal2]=rdsamp('200m');
%       if(sum(abs(signal-signal2)) !=0);
%          error('Record not compatible with RDMAT');
%       end
%
%
% Written by Ikaro Silva, 2014
% Last Modified: November 17, 2014
% Version 1.1
%
% Since 0.9.7
%
% %Example:
% wfdb2mat('mitdb/200')
%tic;[tm,signal,Fs,siginfo]=rdmat('200m');toc
%tic;[tm2,signal2]=rdsamp('200m');toc
% sum(abs(signal-signal2))
%
%
% See also RDSAMP, WFDB2MAT

%endOfHelp

%Set default pararameter values
inputs={'recordName'};
defGain=200; %Default value for missing gains
wfdbNaN=-32768; %This should be the case for all WFDB signal format types currently supported by RDMAT

for n=1:nargin
    if(~isempty(varargin{n}))
        eval([inputs{n} '=varargin{n};'])
    end
end

outputs={'tm','val','Fs','siginfo'};
fid = fopen([recordName, '.hea'], 'rt');
if(fid==-1)
    error(['Could not open file: ' recordName '.hea !'])
end

%Following the documentation described in :
%http://www.physionet.org/physiotools/wag/header-5.htm
%to parse the header file

%Skip any comment lines
str=fgetl(fid);
while(strcmp(str(1),'#'))
    str=fgetl(fid);
end

%Process Record Line Info
info=textscan(str,'%s %u %f %u');
M=info{2}; %Number of signals present
Fs=info{3};

%Process Signal Specification lines. Assumes no comments between lines.
siginfo=[];
for m = 1:M
    str=fgetl(fid);
    info=textscan(str,'%s %s %s %u %u %f %u %u %s');
    gain=info{3}{:};
    
    %Get Signal Units if present
    ind=strfind(gain,'/');
    if(~isempty(ind))
        siginfo(m).Units=gain(ind+1:end);
        gain=gain(1:ind-1);
    end
    
    %Get Signal Baseline if present
    ind=strfind(gain,'(');
    if(~isempty(ind))
        ind2=strfind(gain,')');
        siginfo(m).Baseline=str2num(gain(ind+1:ind2-1));
        gain=gain(1:ind-1);
    else
        %If Baseline is missing, set it equal to ADC Zero
        adc_zero=info{5};
        if(~isempty(adc_zero))
            siginfo(m).Baseline=double(adc_zero);
        else
            error('Could not obtain signal baseline');
        end
    end
    
    %Get Signal Gain
    gain=str2num(gain);
    if(gain==0)
        %Set gain to default value in this case
        gain=defGain;
    end
    siginfo(m).Gain=double(gain);
    
    
    %Get Signal Descriptor
    siginfo(m).Description=info{9}{:};
    
end
fclose(fid);

load([recordName '.mat']);
val(val==wfdbNaN)= NaN;
for m = 1:M
    %Convert from digital units to physical units.
    % Mapping should be similar to that of rdsamp.c:
    % http://www.physionet.org/physiotools/wfdb/app/rdsamp.c
    val(m, :) = (val(m, :) - siginfo(m).Baseline ) / siginfo(m).Gain;
end

%Reshape to the Toolbox's standard format
val=val'; 

%Generate time vector
N=size(val,1);
tm =linspace(0,(N-1)/Fs,N);


for n=1:nargout
    eval(['varargout{n}=' outputs{n} ';'])
end


end
