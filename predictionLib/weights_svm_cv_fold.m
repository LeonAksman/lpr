function w      = weights_svm_cv_fold(struct_cv)

trIndx_i        = struct_cv.d.trainingIndeces;
data_i          = struct_cv.d.featureMat(trIndx_i, :);
    
%mean center the training data
n               = size(data_i, 1);
data_i          = data_i - repmat(mean(data_i, 1), n, 1);

w               = data_i' * struct_cv.alpha;