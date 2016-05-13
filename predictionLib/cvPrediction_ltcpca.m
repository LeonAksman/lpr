%    Cross-validation based prediction function, calling algorithm function for outer/inner CV folds
%    This version is optimized for LTC-PCA
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
function [outStructs_cv, outStruct_full] = cvPrediction_ltcpca(y, dataStruct, algo)

addpath '../PRoNTo_v.1.1_r740/utils';

dataStruct.y                        = y;
dataStruct.X                        = normalizeWithinSamples(dataStruct.data, algo.input.intraSampleNormStyle); 

cvObject                            = feval(@cvpartition, length(y), algo.cv.outerParams{:});

[outStructs_cv, outStruct_full]  	= deal([]);

tic;

%**** cross validation
if algo.cv.parallelize
    
    p                             	= setupParallelization(algo.cv.numWorkers);
    parfor i = 1:cvObject.NumTestSets
        outStruct_i              	= outerFold(i, cvObject, algo, dataStruct);    
        outStructs_cv           	= [outStructs_cv;  outStruct_i];
    end
    delete(p);
    
else
    for i = 1:cvObject.NumTestSets
        outStruct_i               	= outerFold(i, cvObject, algo, dataStruct);    
        outStructs_cv            	= [outStructs_cv;  outStruct_i];
    end
end

%***** train on full data
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
outStruct_full.targets              = [];

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

targetIndices                       = find(cvObject.test(i));

%*** run the machine learning algo
outStruct_i                      	= feval(algo.fnHandle, d, algo.args);    
outStruct_i.d                       = d;
outStruct_i.targets                 = d.te_targets;    
outStruct_i.targetIndices           = targetIndices;


%*****************************************************
function optimal_algo_input         = nestedTuneAlgoParam(trainingIndeces, dataStruct, algo)

assert(algo.input.P == 1 && strcmp(algo.input.lmPCA.setOperation, 'intersect'));
    
if isempty(algo.cv.nestedField)    
    optimal_algo_input           	= algo.input;
    return;
end

allVars                             = algo.input.(algo.cv.nestedField); 
%for optimization
[allVars, indexVarSort]             = sort(allVars, 'descend');

if length(allVars) == 1
    optimal_algo_input           	= algo.input;
    return;
end

numClasses                          = length(unique(dataStruct.y));

dataStruct_i                        = dataStruct;
dataStruct_i.y                      = dataStruct.y(trainingIndeces, :); 
dataStruct_i.X                      = dataStruct.X(trainingIndeces, :); 
 
X_i                                 = dataStruct_i.X;
   
cvObject_nested                  	= feval(@cvpartition, length(trainingIndeces), algo.cv.innerParams{:});


[targets, predictions, funcVals, probabilities]  = deal([]); 
for j = 1:cvObject_nested.NumTestSets
    
    trainingIndeces_j               = cvObject_nested.training(j);
    
    %****** find all principal components ************* %
    fractionVarExplained            = 1;   
          
    coeffs_P1                       = dataStruct.ltcPCA.coeffs_P1;
  	[~, ia]                         = intersectAll(coeffs_P1.ids, dataStruct.id(trainingIndeces_j));                   
   	coeff_mat                    	= coeffs_P1.B_p1(ia, :);        
    %************************************************** %
    
    pcaStruct                       = pcaQuick_explainedVar(coeff_mat, fractionVarExplained);    
    pcaEvalSums                   	= cumsum(pcaStruct.evals)/sum(pcaStruct.evals);
    X_j                           	= X_i * pcaStruct.transform;
    
    [targets_k,     ...
     predictions_k, ... 
     funcVals_k,    ...
     probs_k]                       = deal([]);    
    pcIndex_k_prev                  = 0;
  	for k = 1:length(allVars)
        
        pcIndex_k                   = min(find(pcaEvalSums >= allVars(k)));
              
        %if number of pc's different from before, update prediction, otherwise
        %keep from previous iteration
        if pcIndex_k ~= pcIndex_k_prev
        
            dataStruct_i.X          = X_j(:, 1:pcIndex_k);
            
            inputParams_k                      	= algo.input;
            inputParams_k.(algo.cv.nestedField)	= allVars(k);

            d_k                 	= formAlgoInputStruct_local(dataStruct_i,                   ...
                                                             	cvObject_nested.training(j),    ...
                                                               	cvObject_nested.test(j),        ...
                                                              	inputParams_k);
            
            [~, outStruct_k]        = evalc('feval(algo.fnHandle, d_k, algo.args)'); %feval(algo.fnHandle, d_k, algo.args); 
        end
        
        pcIndex_k_prev              = pcIndex_k;
        
        targets_k                   = [targets_k       d_k.te_targets];
        predictions_k               = [predictions_k   outStruct_k.predictions];
        funcVals_k                  = [funcVals_k      outStruct_k.func_val];
        probs_k                     = [probs_k         outStruct_k.func_val];
    end
   
    targets                         = [targets;         targets_k];
    predictions                     = [predictions;     predictions_k];
    funcVals                        = [funcVals;        funcVals_k];
    probabilities                   = [probabilities;   probs_k];
end

[evalMatrix_bacc, evalMatrix_deviance] = deal(zeros(length(allVars), 1));
for j = 1:length(allVars)
    
    targets_j                     	= targets(:, j);
    probabilities_j                 = probabilities(:, j);
    predictions_j                   = predictions(:, j);
    funcVals_j                      = funcVals(:, j);
    
    %if it's a probabilistic two-class problem adjust the
    %predictions, otherwise use the ones coming out of the
    %algorithm
    if algo.isProbabilistic && numClasses == 2
        
        n                        	= length(targets_j);
        n1                        	= sum(targets_j == 1);                     
        predictions_j             	= prob2TwoClass(probabilities_j, n1/n);                                                         

        %convert 1-2 targets to 0-1 targets
        binaryTargets                   = zeros(length(targets_j), 1);
        binaryTargets(targets_j == 2)   = 1;
        evalMatrix_deviance(j)          = -binomialDeviance(binaryTargets, probabilities_j);     %take the negative value 
    end   
   
    metrics_j                       = performanceMetrics(targets_j, predictions_j, funcVals_j);              
    evalMatrix_bacc(j)              = metrics_j.bacc; 
end

%***** choose best performing value of param
allVars                             = allVars(indexVarSort);
evalMatrix_bacc                     = evalMatrix_bacc(indexVarSort);
evalMatrix_deviance                 = evalMatrix_deviance(indexVarSort);

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



%************************************************
%***************************************************************
function [d, featureMat]            = formAlgoInputStruct_local(dataStruct, trainingIndeces, testIndeces, params)

X                                   = dataStruct.X;

ytrain                              = dataStruct.y(trainingIndeces);
ytest                               = dataStruct.y(testIndeces);

Xtrain                              = X(trainingIndeces, :);
Xtest                               = X(testIndeces, :);

%*** no projection step here

%**** normalization between samples
if ~strcmp(params.interSampleNormStyle, 'none')
    
    switch params.interSampleNormStyle
        case 'meanStd'
            centerX              	= mean(Xtrain, 1);
            dispersionX          	= std(Xtrain);
    
        case 'medianIqr'
            centerX              	= median(Xtrain, 1);
            dispersionX          	= iqr(Xtrain, 1);   
            
        otherwise
            error(['Unknown params.interSampleNormStyle ' params.interSampleNormStyle]);
    end
    indexGoodVariance               = find(dispersionX > 0);
    centerX                       	= centerX(indexGoodVariance);
    dispersionX                  	= dispersionX(indexGoodVariance); %ones(1, length(indexGoodVariance)); 
    
    Xtrain                          = Xtrain(:, indexGoodVariance);
    Xtest                           = Xtest(:, indexGoodVariance);
           
    Xtrain                        	= (Xtrain  - repmat(centerX, size(Xtrain, 1), 1)) ./ repmat(dispersionX, size(Xtrain, 1), 1);
    if ~isempty(testIndeces)
        Xtest                       = (Xtest - centerX) ./ dispersionX;
    end    
end

%reform the original matrix with modified training, testing data
X                                   = zeros((size(Xtrain, 1) + size(Xtest, 1)), size(Xtrain, 2));
X(trainingIndeces, :)               = Xtrain;
if ~isempty(testIndeces)
    X(testIndeces, :)               = Xtest;        
end

% featureMat                        = zeros((size(Xtrain, 1) + size(Xtest, 1)), size(Xtrain, 2));
% featureMat(trainingIndeces, :)    = Xtrain;
% if ~isempty(testIndeces)
%     featureMat(testIndeces, :)  	= Xtest;
% end
featureMat                          = X;

d.trainingIndeces                   = trainingIndeces;
d.testIndeces                       = testIndeces;


%**** form the kernel
if params.formKernel

    recomputeKernel                 = params.ltcPCA                                || ...
                                      ~strcmp(params.interSampleNormStyle, 'none') || ...
                                      ~isfield(dataStruct, 'kernel');  
    if recomputeKernel
        kernel                   	= X * X';      
    else
        kernel                      = dataStruct.kernel;
    end       
    d.kernel                        = kernel; 
    
    kernelTrain                     = kernel(trainingIndeces, trainingIndeces);
    kernelTestTrain                 = kernel(testIndeces,     trainingIndeces);
    kernelTestTest                  = kernel(testIndeces,     testIndeces);

         
    [kernelTrain, kernelTestTrain, kernelTestTest] = ...
                                     prt_centre_kernel(kernelTrain, kernelTestTrain, kernelTestTest);

                  
    d.train{1}                      = kernelTrain;
    d.test{1}                       = kernelTestTrain;
    d.testcov{1}                    = kernelTestTest;
    d.use_kernel                    = true;
else      

    d.train{1}                      = double(Xtrain);
    d.test{1}                       = double(Xtest);
    d.use_kernel                    = false;
end

d.tr_targets                        = ytrain;
d.te_targets                        = ytest;

d.pred_type                         = params.pred_type;
