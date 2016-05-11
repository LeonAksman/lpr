function [maxVal, i, j]     = maxMat(X, mode)

if nargin < 2
    mode                    = 'first';
end

if strcmp(mode, 'first')
    [maxVal, maxLinearIndex] = max(X(:));
    [i, j]                  = ind2sub(size(X), maxLinearIndex);
else
    maxVal                  = max(X(:));
    
    allMaxIndeces       	= find(X(:) == maxVal);
    [i, j]                  = ind2sub(size(X), allMaxIndeces);
end