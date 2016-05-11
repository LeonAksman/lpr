function [Xout, indxBadCols, indxGoodCols]    = cleanMat(Xin, dim, replaceVal)

if nargin < 3
    replaceVal                  = [];
end

assert(dim == 1); %for now

indxBadCols                     = find(max(isnan(Xin), [], dim));

Xout                            = Xin;
Xout(:, indxBadCols)            = replaceVal;


indxGoodCols                    = setdiff(1:size(Xout, 2), indxBadCols);
