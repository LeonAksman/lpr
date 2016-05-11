function w = prt_compute_weights(indextrain,model)

% FORMAT w = prt_compute_weights(path_data,indextrain,PRT)
%
% This function computes the weights in the primal for a kernel based machine 
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Mourao-Miranda

% test if the field model.alpha exists, if not return w = [];

for i=1:length(model.alpha)
    
    
    fname = [prt_get_filename([indextrain(i).group,indextrain(i).subject,indextrain(i).modality,indextrain(i).cond]),'.img'];
    
    traindata=nifti(fname);
    
    tmp1 = single(reshape(traindata.dat(:,:,:,indextrain(i).scan),1,size(traindata.dat,1)*size(traindata.dat,2)*size(traindata.dat,3)));% train example i
    tmp2 = single(model.alpha(i));
    
    if i==1
        w=zeros(size(tmp1),'single');
    else
        w = w + tmp1 * tmp2;
    end
end



return