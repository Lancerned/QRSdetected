function RMS = RMSCalculate( input, head, tail )
RMS = 0;
if head >= tail
    return;
end
sumsquare = sum( ( input( head+1:tail ) - input( head:tail-1 ) ).^2 );
RMS = sumsquare / ( tail - head );

end