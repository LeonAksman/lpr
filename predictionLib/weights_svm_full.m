function w      = weights_svm_full(in)

disp('running weights_svm_full...');


%data            = in.struct_full.d.featureMat;
data            = in.struct_full.featureMat;
n               = size(data, 1);
data            = data - repmat(mean(data, 1), n, 1);

w               = data' * in.struct_full.alpha;

disp('done.');