function maps                                   = calcWeightForwardMaps(in, algo)

addpath '../mapping';

mask                                            = loadMask(in.maskFilename, in.maskValidIndeces);

%******************** t map
index1                                          = find(in.struct_full.targets==1);
index2                                          = find(in.struct_full.targets==2);

data                                            = in.struct_full.featureMat;

[~, p, ~, stats]                             	= ttest2(data(index1, :), data(index2, :));
pMax                                            = 1; %.0001;
stats.tstat(p > pMax)                         	= 0;

maps.t                                          = featuresToImage(stats.tstat, mask, 'save', algo.t_nii_filename);  


%******************** weight map
w_vec                                           = feval(algo.fnHandle_weights_full, in);  
w_vec                                           = w_vec ./ max(abs(w_vec));

maps.weight                                   	= featuresToImage(w_vec, mask, 'save', algo.w_nii_filename);   


%******************** forward cov map
n                                               = size(data, 1);
data_centered                                   = data - repmat(mean(data, 1), n, 1);

funcVals                                        = [in.struct_full.func_val]';
funcVals_centered                            	= funcVals - mean(funcVals);

cov_map                                     	= (data_centered' * funcVals_centered')/(n-1);
cov_map                                         = cov_map ./ max(abs(cov_map));

maps.forward_cov                                = featuresToImage(cov_map, mask, 'save', algo.cov_map_nii_filename);   

%******************** forward map
Xc                                              = data_centered ./ sqrt(n-1);
    

%we are using the predicted function values here - in theory we should
%subtract off the offset b from those values if it's an SVM for example -> it doesn't really matter
%though as all these constants simply scale the map (fc'*fc is a scalar) and we divide by abs(max(fwd_map)) in the end anyway
fc                                              = (funcVals_centered ./ sqrt(n-1))';
fwd_map                                         = (Xc' * (Xc * w_vec)) ./ (fc'*fc);
fwd_map                                         = fwd_map ./ max(abs(fwd_map));

maps.forward                                   	= featuresToImage(fwd_map, mask, 'save', algo.fwd_map_nii_filename);       


