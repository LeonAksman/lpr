%    Demo of an analysis using unbalanced LM-PCA, with short intervals between scans
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
function metrics                        = demo_lmpca_short(runMode, logFilename) 

inDir                                   = '../demo_data';                                         %the directory with where all data lives
outMetricsFilename                    	= ''; % fullfile(inDir, 'outDir', 'metrics_ltcpca.mat');  %the location of the output metrics filename - currently not specified

addpath '../utils';
addpath '../predictionLib';
addpath '../PRoNTo_v.1.1_r740/machines'; 

%runMode is 'std' (standard) or 'debug', which won't tune explained variance
if nargin == 0
    runMode                             = 'std';
end

%logger - not used much here, but useful
if nargin == 2
    logger                              = log4m.getLogger(logFilename);
    logger.setCommandWindowLevel(logger.ALL);
    logger.setLogLevel(logger.ALL);
end

in.DEBUG                                = conditional(strcmp(runMode, 'debug'), true, false); %if 'debug' argument, set debug mode

in.metricsFilename                     	= outMetricsFilename;
in.analysisName                         = 'OASIS LM-PCA (short)';

in.algo.input.minClassificationSetSamples   = 3;                                    %minimum number of samples per subject (longitudinally)
in.algo.input.P                             = 1;                                    %the polynomial model order in LTC-PCA
in.algo.input.samplesChosen                 = 'lastTwo';                        	%how many samples to use from each subject - 'all'/'lastTwo'/'firstLast' 

in.algo.input.ltcPCA                    = true;                                     %if true create LTC-PCA projection and project cross-sectional data onto the subspace
in.algo.input.explainedVar             	= conditional(~in.DEBUG, 0.05:0.05:0.95, 0.9);     %if debug fix explained variance


%***************************************************
%the pattern recognition algorithm's parameters
%currently an SVM is used here, specifically the LIBSVM implementation with wrapper from PRoNTo
%
%can also be used with the Gaussian Process classifier from the GPML toolbox, wrapped with PRoNTo here

% algo choice

%*** SVM: LibSVM version
in.algo.name                             = 'libsvm';
in.algo.isProbabilistic                  = false;
in.algo.fnHandle                         = @prt_machine_svm_bin;
in.algo.fnHandle_weights_cv              = @weights_svm_cv;  
in.algo.fnHandle_weights_full            = @weights_svm_full;  
in.algo.formKernel                       = true;
in.algo.args                             = '-s 0 -t 4 -c 1';
in.algo.evalStyle                        = 'bacc';


%***** GPC
% in.algo.name                             = 'gpc';
% in.algo.isProbabilistic                  = true;
% in.algo.fnHandle                         = @prt_machine_gpml; 
% in.algo.fnHandle_weights_cv              = [];  
% in.algo.fnHandle_weights_full            = [];  
% in.algo.formKernel                       = true;
% in.algo.args                             = '-l erf -h';       
% in.algo.evalStyle                        = 'bacc';          %'deviance';        

%**************************************************************%
  
%************* setup: analysis parameters

enableParfor                            = false;

in.algo.cv.fnHandle                      = @cvPrediction_ltcpca;                    %function handle for cross-validation function to use - this version has been optimized for ltc-pca
in.algo.cv.parallelize                   = conditional(~in.DEBUG, enableParfor, false);     %if not debug  and parallelization (parfor) enabled, use parallelization
in.algo.cv.numWorkers                    = 12;                                      %how many parallel workers to use
in.algo.cv.outerParams                   = {'Leaveout'};                            %cross-validation style for outer CV folds, used in cvpartition function
in.algo.cv.innerParams                 	 = {'Leaveout'};                            %cross-validation style for inner CV folds, used in cvpartition function
in.algo.cv.nestedField                   = 'explainedVar';                          %which field we are tuning with inner (nested) CV, set as '' when no inner CV   

in.algo.input.pred_type                  = 'classification';
in.algo.input.formKernel                 = true;
in.algo.input.intraSampleNormStyle       = 'none';        
in.algo.input.interSampleNormStyle       = 'none';        
in.algo.input.fnHandle                   = @formAlgoInputStruct_ltcpca;             %function handle for forming input data to algorithm
in.algo.input.lmPCA.setOperation         = 'intersect';                             %intersect longitudinal subject set with classification subject set
                                                                                    %can have 'setdiff' for information transfer style, not currently supported

in.algo.input.constants.TRAINING_AND_TEST 	= 0;
in.algo.input.constants.TRAINING_ONLY      	= 1;
in.algo.input.pruningStyle                 	= in.algo.input.constants.TRAINING_ONLY;

%************* setup: input

in.maskFilename                         = fullfile(inDir, 'mask.nii');              %mask to apply to all images
in.maskValidIndeces                     = [];                                   

in.crossSectionalMapping             	= fullfile(inDir, 'allFields_lastTP.txt');  %all image filepaths and corresponding informationg: mr id, subject id, time of scan (from baseline here), class label at time of scan
in.longitudinalMapping               	= fullfile(inDir, 'allFields_allTPs.txt');  %same as above for longitudinal data

in.delays                               = [];                                       %can restrict times to certain range
in.intersectWithLongitudinal            = true;                                     %intersect longitudinal subjects with classification subjects


in.diseaseStates                        = {'0', '0.5', '1', '2'};                   %all possible disease states

%************* setup: classify
in.label                                = 'CDR 1.0/0.5 vs CDR 0';                   %label for this classification problem
in.classLabels                          = {'1.0/0.5',   '0'};                       %which two classes are being discriminated
in.groupings                            = {[3 2],       [1]};                       %form first class by combining group 3 (1.0 CDR) and group 2 (0.5 CDR), discrminated againt group 1 (0 CDR)


%************* setup: function handles
in.fnLoad                               = @loadLongitudinalData_general;            %function handle for longitudinal data loading function
in.fnAnalyze                            = @classify;                                %function handle for classification
in.fnEvaluate                           = @evaluate;                                %function handle for evaluation of classifier performance


%************* run analysis
metrics                                 = runAnalysis(in);                          %run the analysis, passing in the structure ('in') we've setup here
