%function [indexBestSubset, bestMatchVal] = matchHistogramsViaResampling(dataRef, dataToMatch, params.numResamplings, params.numHistBins)
function [indexBestSubset, bestMatchVal] = matchHistogramsViaResampling(dataRef, dataToMatch, params)


nRef                = length(dataRef);
nToMatch            = length(dataToMatch);

assert(nRef < nToMatch);

warning off;
assert(nchoosek(nToMatch, nRef) > params.numResamplings);
warning on;
% numCombos           = nchoosek(nToMatch, nRef);
% if numCombos < params.numResamplings
%     disp(sprintf('matchHistogramsViaResampling: numCombos: %d < params.numResamplings: %d', numCombos, params.numResamplings));
%     
%     indexBestSubset = 1:nToMatch;
%     bestMatchVal    = 0;
%     
%     return;
% end

allData             = [single(dataRef); single(dataToMatch)];
[minVal, maxVal]    = deal(min(allData), max(allData));
centers             = linspace(minVal, maxVal, params.numHistBins);

histRef             = histc(single(dataRef), centers); %params.numHistBins
%gaussWinLen         = 3;
%histRef             = gaussSmooth(histRef, gaussWinLen);

%rng(params.seed);

bestMatchVal      	= -Inf;
indexBestSubset     = [];
for i = 1:params.numResamplings
    perm_i          = randperm(nToMatch, nRef);
    
    histToMatch_i   = histc(single(dataToMatch(perm_i)), centers); %params.numHistBins
    %histToMatch_i  	= gaussSmooth(histToMatch_i, gaussWinLen);

    matchVal        = histogramIntersectionKernel(histRef, histToMatch_i);
    
    if matchVal > bestMatchVal
        bestMatchVal   	= matchVal;
        indexBestSubset = perm_i;
    end
end