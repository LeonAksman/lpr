%    Performance metrics based on analyzing actual targets, predicted targets and classifier function values
%    Copyright (C) 2016  Leon Aksman
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>
%
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
