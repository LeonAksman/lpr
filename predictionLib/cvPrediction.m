function [outStructs_cv, outStruct_full] = cvPrediction(y, dataStruct, algo)

addpath '../PRoNTo_v.1.1_r740/utils';
addpath '../pca';

dataStruct.y                        = y;
dataStruct.X                        = normalizeWithinSamples(dataStruct.data, algo.input.intraSampleNormStyle); 


%cvObject                            = cvpartition(length(y), 'Leaveout');
cvObject                            = feval(@cvpartition, length(y), algo.cv.outerParams{:});

outStructs_cv                       = [];

tic;

%**** cross validation
if algo.cv.parallelize
    parfor i = 1:cvObject.NumTestSets
        outStruct_i              	= outerFold(i, cvObject, algo, dataStruct);    
        outStructs_cv           	= [outStructs_cv;  outStruct_i];
    end
else
    for i = 1:cvObject.NumTestSets
        outStruct_i               	= outerFold(i, cvObject, algo, dataStruct);    
        outStructs_cv            	= [outStructs_cv;  outStruct_i];
    end
end

%***** train on full data, predict (test) on full data
disp('***** cvPrediction: full training');

trainingIndeces_full              	= true(length(y), 1); 
testingIndeces_full                 = true(length(y), 1); 

optimal_algo_input                  = nestedTuneAlgoParam(trainingIndeces_full, dataStruct, algo);


[d, featureMat]                     = feval(algo.input.fnHandle,    ...
                                            dataStruct,             ...   
                                            trainingIndeces_full,  	...
                                            testingIndeces_full,    ...
                                            optimal_algo_input);          

outStruct_full                      = feval(algo.fnHandle, d, algo.args);
outStruct_full.d                    = d;
outStruct_full.featureMat           = featureMat;
outStruct_full.targets              = d.te_targets;

toc;

%*****************************************************
function outStruct_i                = outerFold(i, cvObject, algo, dataStruct)

disp(sprintf('***** cvPrediction: %2d/%2d', i, cvObject.NumTestSets));  

trainingIndeces_i                   = find(cvObject.training(i));

optimal_algo_input                  = nestedTuneAlgoParam(trainingIndeces_i, dataStruct, algo);

d                                   = feval(algo.input.fnHandle, 	...
                                            dataStruct,             ...    
                                            cvObject.training(i),   ...
                                            cvObject.test(i),       ...
                                            optimal_algo_input);

if isempty(d)
    disp('Skipping.'); 
    newline();

    return;
end

targetIndices                   = find(cvObject.test(i));

%for use in next iteration
%if isfield(d, 'kernel')
%    dataFull.kernel         	= d.kernel;
%end

%*** run the machine learning algo
outStruct_i                     = feval(algo.fnHandle, d, algo.args);    
outStruct_i.d                   = d;
outStruct_i.targets             = d.te_targets;    
outStruct_i.targetIndices       = targetIndices;

%*****************************************************
function optimal_algo_input         = nestedTuneAlgoParam(trainingIndeces, dataStruct, algo)

if isempty(algo.cv.nestedField)    
    optimal_algo_input           	= algo.input;
    return;
end

allVars                             = algo.input.(algo.cv.nestedField); 

if length(allVars) == 1
    optimal_algo_input           	= algo.input;
    return;
end

numClasses                          = length(unique(dataStruct.y));

dataStruct_i                        = dataStruct;
dataStruct_i.y                      = dataStruct.y(trainingIndeces, :); 
dataStruct_i.X                      = dataStruct.X(trainingIndeces, :); 

%cvObject_nested                     = cvpartition(length(trainingIndeces), 'Leaveout');    
cvObject_nested                  	= feval(@cvpartition, length(trainingIndeces), algo.cv.innerParams{:});

[evalMatrix_bacc, evalMatrix_deviance] = deal(zeros(length(allVars), 1));

%**** loop over parameter of interest  
for j = 1:length(allVars)           %parfor not used at this level currently
    
    disp(sprintf('***************** Evaluating parameter value: %.2f, iteration %d/%d', allVars(j), j, length(allVars)));

    inputParams_j                           = algo.input;
    inputParams_j.(algo.cv.nestedField)     = allVars(j);    

    [targets_j,         ...
     predictions_j,     ...
     funcVals_j,        ...
     probabilities_j]               = deal([]); 

    for k = 1:cvObject_nested.NumTestSets

        d_k                         = feval(algo.input.fnHandle,          	...
                                            dataStruct_i,                   ... 
                                            cvObject_nested.training(k),    ...
                                            cvObject_nested.test(k),        ...
                                            inputParams_j);
        if isempty(d_k)
            %disp(sprintf('Skipping index: %d', k));
            continue;
        end

        outStruct_i                 = feval(algo.fnHandle, d_k, algo.args); 

        targets_j                   = [targets_j;       d_k.te_targets];   
        predictions_j               = [predictions_j;   outStruct_i.predictions];   
        funcVals_j                  = [funcVals_j;      outStruct_i.func_val];
        probabilities_j             = [probabilities_j; outStruct_i.func_val];
    end  

    %if it's a probabilistic two-class problem adjust the
    %predictions, otherwise use the ones coming out of the
    %algorithm
    if algo.isProbabilistic && numClasses == 2
        n                           = length(targets_j);
        n1                          = sum(targets_j == 1);                     
        predictions_j               = prob2TwoClass(probabilities_j, n1/n);                                                         

        %convert 1-2 targets to 0-1 targets
        binaryTargets               = zeros(length(targets_j), 1);
        binaryTargets(targets_j == 2) = 1;
        evalMatrix_deviance(j)      = -binomialDeviance(binaryTargets, probabilities_j);     %take the negative value 
    end            

    metrics_j                       = performanceMetrics(targets_j, predictions_j, funcVals_j);              
    evalMatrix_bacc(j)              = metrics_j.bacc; 
end

%***** choose b`est performing value of param
switch algo.evalStyle
    case 'bacc'
        [~, indexBestParam]         = max(evalMatrix_bacc);                
    case 'deviance'
        assert(algo.isProbabilistic && numClasses == 2);
        [~, indexBestParam]         = max(evalMatrix_deviance);                
    otherwise
        error(['Unknown evalStyle ' algo.evalStyle]);                
end

optimal_algo_input                      = algo.input;
optimal_algo_input.(algo.cv.nestedField)   = allVars(indexBestParam);

disp(sprintf('***************** Choosing parameter value: %.2f', optimal_algo_input.(algo.cv.nestedField)));

