function w      = weights_svm_cv(in)

disp('running weights_svm_cv...');


%w               = in.dataStruct.data' * in.struct_full.alpha;


%average the cross-validation folds' weights
w_mat        	= zeros(size(in.dataStruct.data'));
for i = 1:length(in.structs_cv)    
    trIndx_i    = in.structs_cv(i).d.trainingIndeces;
    data_i      = in.structs_cv(i).d.featureMat(trIndx_i, :);
    
    %mean center the training data
    n           = size(data_i, 1);
    data_i      = data_i - repmat(mean(data_i, 1), n, 1);
    
    w_mat(:, i) = data_i' * in.structs_cv(i).alpha;
end

w               = mean(w_mat, 2);

disp('done.');