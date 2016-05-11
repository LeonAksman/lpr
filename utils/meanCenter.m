function [X_centered, X_mean]   = meanCenter(X, dim)

[dim1, dim2]                    = size(X);

X_mean                       	= mean(X, dim);

switch dim
    case 1
        X_centered              = X - repmat(X_mean, dim1, 1);
    case 2
        X_centered              = X - repmat(X_mean, 1,    dim2);
    otherwise
        error('unknown dim');
end