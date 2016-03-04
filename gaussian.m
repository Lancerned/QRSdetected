function [ result ] = gaussian( input, sigma )
%UNTITLED6 Summary of this function goes here
%   Detailed explanation goes here

if nargin < 2
    sigma = 1.5;
end
e = 2.7183;

result = e.^( -input.^2 / ( 2 * sigma.^2 ) );
end

