function   metrics                  = performanceMetrics(target, prediction, funcVals)

if nargin < 3
    funcVals                        = [];
end

C                                   = confusionmat(target, prediction);

%metrics.target                      = target;
%metrics.prediction                  = prediction;

metrics.cacc                        = diag(C) ./ sum(C,2);
%metrics.cpv                        = diag(C) ./ sum(C)';
metrics.acc                         = sum(diag(C)) / sum(sum(C));
metrics.bacc                        = mean(metrics.cacc);

if any(size(C) ~= [2 2])
    %disp('performanceMetrics: C is not [2 2]: {sensitivity, specificity, ppv, npv} stats will not be calculated.');
    return;
end

metrics.sensitivity                 = C(1,1)/sum(C(1, :));
metrics.specificity                 = C(2,2)/sum(C(2, :));
metrics.ppv                         = C(1,1)/sum(C(:, 1));
metrics.npv                         = C(2,2)/sum(C(:, 2));

%metrics.auc                         = calcRocAuc(target, funcVals);

%convert {1,2} to {1,-1} style
assert(all(asRowCol(unique(target), 'row') == [1 2]));
target(find(target==2))             = -1;

if ~isempty(funcVals)
    %funcVals                     	= sign(funcVals);
    %[~, ~, ~, metrics.auc]        	= perfcurve(funcVals, target, 1);

    [~, ~, ~, metrics.auc]        	= perfcurve(target, funcVals, 1);
end