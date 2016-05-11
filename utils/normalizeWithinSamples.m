function [Xnormed, center, dispersion] = normalizeWithinSamples(X, normStyle, samplesDimension)

if nargin < 3
    samplesDimension                = 'row';
end

if strcmp(samplesDimension, 'col')
    X                               = X';
end

[center, dispersion]                = deal([]);

switch normStyle
    case 'meanStd'
        [center, dispersion]      	= deal(mean(X, 2), std(X, 0, 2));
        Xnormed                  	= (X - repmat(center, 1, size(X, 2))) ./ repmat(dispersion, 1, size(X, 2));
        
    case 'medianIqr'
        [center, dispersion]      	= deal(median(X, 2), iqr(X, 2));
        Xnormed                    	= (X - repmat(center, 1, size(X, 2))) ./ repmat(dispersion, 1, size(X, 2));
        
    case 'none'
        Xnormed                     = X;
        
    otherwise
        error(['Unknown algo.intraSampleNormStyle ' algo.sampleNormStyle]);
end

if strcmp(samplesDimension, 'col')
    center                          = center';
    dispersion                      = dispersion';
    Xnormed                         = Xnormed';
end
