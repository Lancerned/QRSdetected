
function iECGs = mwintegration( ECGs, idxWindow )
if nargin < 2
    idxWindow = 60;
end

iECGs = ECGs;

for i = 1:idxWindow
    iECGs(1:end-idxWindow,:) = iECGs(1:end-idxWindow,:) + ECGs( 1+i:end-idxWindow+i,: );
end

end