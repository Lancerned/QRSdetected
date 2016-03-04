function [ output ] = rms( input, idxWindow )
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
if nargin < 2
    idxWindow = 40;
end

temple = input.^2;
output = zeros( size(input) );
idx = ceil( idxWindow / 2 );
for i = 1:idx
    
    output( idx+1:end-idx,: ) = output( idx+1:end-idx,:) + temple( idx+1-i:end-idx-i,: );
    output( idx+1:end-idx,: ) = output( idx+1:end-idx,:) + temple( idx+1+i:end-idx+i,: );
    
end

output = output / idxWindow;
output( idx+1:end-idx-1,: ) = output(idx+2:end-idx,:) ./ output( idx+1:end-idx-1,: );

end
