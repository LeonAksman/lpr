%***************************************************************
function [d, featureMat]            = formAlgoInputStruct(dataStruct, trainingIndeces, testIndeces, params)

%make sure they're logically indexed
assert(islogical(trainingIndeces) 	&& ...
       islogical(testIndeces)       && ...
       length(trainingIndeces) == length(testIndeces));

X                                   = dataStruct.X;

ytrain                              = dataStruct.y(trainingIndeces);
ytest                               = dataStruct.y(testIndeces);

Xtrain                              = X(trainingIndeces, :);
Xtest                               = X(testIndeces, :);
    
%normalization between samples
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
%X                                   = zeros((size(Xtrain, 1) + size(Xtest, 1)), size(Xtrain, 2));
allIndex                            = max(trainingIndeces, testIndeces); %must be used with logical indexing
X                                   = zeros(length(allIndex), size(Xtrain, 2));

X(trainingIndeces, :)               = Xtrain;
if ~isempty(testIndeces)
    X(testIndeces, :)               = Xtest;        
end
featureMat                          = X;

d.trainingIndeces                   = trainingIndeces;
d.testIndeces                       = testIndeces;


if params.formKernel

    recomputeKernel                 = ~strcmp(params.interSampleNormStyle, 'none') || ~isfield(dataStruct, 'kernel');  
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
