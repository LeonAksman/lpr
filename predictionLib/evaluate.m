function metrics            = evaluate(in, analysisOutput)


targets                     = [analysisOutput.structs_cv.targets];

uniqueClasses             	= unique(targets);
numClasses                  = length(uniqueClasses);

funcVals                    = [analysisOutput.structs_cv.func_val];

if in.algo.isProbabilistic && numClasses == 2

    n1                    	= sum(targets == 1); 
    n2                     	= sum(targets == 2);
    n                    	= n1+n2;

    probabilities        	= funcVals;

    predictions_even     	= prob2TwoClass(probabilities, 0.5);
    predictions_adjusted    = prob2TwoClass(probabilities, n1/n);

    funcVals_even           = predictions_even;
    funcVals_adjusted      	= predictions_adjusted;

    metrics_even            = performanceMetrics(targets, predictions_even,     funcVals_even);
    metrics_adjusted        = performanceMetrics(targets, predictions_adjusted, funcVals_adjusted);

    dispLabel(in, targets);
    out_even                = dispPredStats(metrics_even,     'Threshold: 50%');
    out_adj                 = dispPredStats(metrics_adjusted, sprintf('Threshold: %2d%% (n1/n)', int32(n1/n * 100)));         

    %for output
    predictions             = [analysisOutput.structs_cv.predictions];
    metrics                 = metrics_adjusted;
    metrics.outString       = sprintf('%s\r%s', out_even, out_adj);
else
    dispLabel(in, targets);

    predictions             = [analysisOutput.structs_cv.predictions];
    metrics                 = performanceMetrics(targets, predictions, funcVals);
    metrics.outString       = dispPredStats(metrics, 'Raw'); 

end

targetIndices                           = [analysisOutput.structs_cv.targetIndices];

[metrics.targets, metrics.predictions]  = deal(zeros(size(targets)));
metrics.targets(targetIndices)          = targets;
metrics.predictions(targetIndices)   	= predictions;

%********************************************
function dispLabel(in, targets)

uniqueClasses             	= unique(targets);
numClasses                  = length(uniqueClasses);

classSizes                  = zeros(numClasses, 1);
for i = 1:numClasses
    classSizes(i)           = length(find(targets == uniqueClasses(i)));
end

label                       = '';
if isfield(in, 'classLabels')
    for i = 1:numClasses
        label            	= [label sprintf('%s (n = %d)', in.classLabels{i}, classSizes(i))];
        if i < numClasses
            label          	= [label ' vs '];
        end
    end
end
disp(['************ ' label ' ************']);
