%    Perform PCA for high dimensional, low sample number feature matrix, i.e. when:
%    X is an N x D matrix, where N is small, D is large
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
function pcaStruct      = pcaQuick_explainedVar(X, fractionVarExplained, computeNullSpace)

if nargin < 3
    computeNullSpace    = false;
end

[N, ~]                  = size(X);

assert(fractionVarExplained > 0 && fractionVarExplained <= 1, 'assert failed: fractionVarExplained > 0 && fractionVarExplained <= 1');

meanX                   = mean(X, 1);
X_meanCentered          = X - repmat(meanX, N, 1);

S                       = 1/N * (X_meanCentered * X_meanCentered');

[evecs, evalsMat]      = eig(S);        %better results than: eigs(S, numComponentsUsed);

%make sure eigenvalues are descending
[evalsFull, indexSorted] = sort(diag(evalsMat), 'descend');
evecs                   = evecs(:, indexSorted);

evalSums                = cumsum(evalsFull)/sum(evalsFull);
indexLastEvalUsed     	= min(find(evalSums >= fractionVarExplained));

% evecsFull        	= zeros(D, numComponentsUsed);
% for i = 1:numComponentsUsed
%     evecsFull(:, i)   	= 1/sqrt(N * evalsFull(i)) * X' * evecs(:, i);
% end 
%same as above, but much faster
d                       = diag(1./sqrt(N * evalsFull(1:indexLastEvalUsed)));
evecsFull            	= X_meanCentered'* (evecs(:, 1:indexLastEvalUsed) * d);

pcaStruct.mean          = meanX;
pcaStruct.transform     = evecsFull;
pcaStruct.evals         = evalsFull(1:indexLastEvalUsed);

if computeNullSpace
    indexNull           = (indexLastEvalUsed+1):(length(evalsFull) - 1);
    d                 	= diag(1./sqrt(N * evalsFull(indexNull)));
    evecsNull         	= X_meanCentered'* (evecs(:, indexNull) * d);
    pcaStruct.null    	= evecsNull;  
end

