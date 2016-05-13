%    Form algorithm (classification,regression) input using raw data and training/test indeces, projecting onto LTC-PCA space
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
function [d, featureMat]            = formAlgoInputStruct_ltcpca(dataStruct, trainingIndeces, testIndeces, params)

%make sure they're logically indexed
assert(islogical(trainingIndeces) 	&& ...
       islogical(testIndeces)       && ...
       length(trainingIndeces) == length(testIndeces));

X                                   = dataStruct.X;

ytrain                              = dataStruct.y(trainingIndeces);
ytest                               = dataStruct.y(testIndeces);

Xtrain                              = X(trainingIndeces, :);
Xtest                               = X(testIndeces, :);

% %******* LTC-PCA projection step   
if params.ltcPCA && isfield(dataStruct, 'ltcPCA')
      
    coeffs_P1                       = dataStruct.ltcPCA.coeffs_P1;
  	
    switch params.lmPCA.setOperation
        case 'intersect'
            [~, ia]               	= intersectAll(coeffs_P1.ids, dataStruct.id(trainingIndeces));               
        case 'setdiff'
            [~, ia]              	= setdiff(coeffs_P1.ids, dataStruct.id(testIndeces));
    end
    
    if params.P  == 1
        B_p1                     	= coeffs_P1.B_p1(ia, :);        
        pcaStruct_B1              	= pcaQuick_explainedVar(B_p1,      	params.explainedVar);      
        T                         	= pcaStruct_B1.transform;   
    
    elseif params.P == 2       
        
        coeffs_P2               	= dataStruct.ltcPCA.coeffs_P2;
        [~, ia]                  	= intersectAll(coeffs_P2.ids, dataStruct.id(trainingIndeces));               

        B_p1                      	= coeffs_P2.B_p1(ia, :);        
        pcaStruct_B1               	= pcaQuick_explainedVar(B_p1,      	params.explainedVar);      
        T                        	= pcaStruct_B1.transform;   
        
        B_p2                       	= coeffs_P2.B_p2(ia, :);          
        pcaStruct_B2              	= pcaQuick_explainedVar(B_p2,       params.explainedVar);  
        T                         	= [T pcaStruct_B2.transform];
    else
        error('params.P == 1 or params.P == 2 for now.');
    end
               	
    Xtrain                          = (Xtrain * T) * T';
    if any(testIndeces)
        Xtest                       = (Xtest * T) * T';
    end
end
    
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
