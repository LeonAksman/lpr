function out    = binomialDeviance(trueLabels, predictedProbability)

%matching lengths
assert(length(trueLabels) == length(predictedProbability));

%valid predicted probabilities
assert(min(predictedProbability) > 0 && max(predictedProbability) < 1, ...
       ['assert failed, predictedProbability vals ' sprintf('%.2f ', predictedProbability)]); 


n               = length(trueLabels);
out             = -1/n * sum(trueLabels.*log(predictedProbability) + (1 - trueLabels).*log(1 - predictedProbability));

