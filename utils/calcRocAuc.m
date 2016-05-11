function auc = calcRocAuc(targets, fVals)

if isrow(targets)
    targets   = targets';
end
if isrow(fVals)
    fVals       = fVals';
end

%convert {1,2} or {1,-1} target class labels to {1,0} style
targpos     = (targets == 1);

[y,idx]     = sort(fVals);
targpos     = targpos(idx);

fp          = cumsum(single(targpos))/sum(single(targpos));
tp          = cumsum(single(~targpos))/sum(single(~targpos));

tp          = [0 ; tp ; 1];
fp          = [0 ; fp ; 1];

n           = size(tp, 1);
auc           = sum((fp(2:n) - fp(1:n-1)).*(tp(2:n)+tp(1:n-1)))/2;