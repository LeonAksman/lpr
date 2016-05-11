function prt_create_weight_maps (PRT,ind_model,C)

% FORMAT prt_create_weight_maps (PRT,ind_model,C)
% This function coreates a 4D NIFTI image correponding to the weights of
% each fold of the model
%
% Inputs
%---------------------------------------------------
% PRT: PRT.mat after training the model
% ind_model: index of the model
% C: cross-validation matrix used to train the model indexed by ind_model
%
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Mourao-Miranda

n_folds=size(C,2);

%find feature used for the model
for i=1:length(PRT.fs)
    if strcmp(PRT.model(ind_model).input.fs_name,PRT.fs(i).fs_name)
        ind_feat=i;
    end
end

%find mask used for the model
mod=PRT.group(PRT.fs(ind_feat).ids(1).group).subject(PRT.fs(ind_feat).ids(1).subject).modality.mod_name; %find modality of the first training example
for i=1:length(PRT.masks)
    if strcmp(PRT.masks(i).mod_name,mod)
        ind_mask=i;
    end
end

sample_img = nifti(char(PRT.masks(ind_mask).fname));
filename = [PRT.model.model_name,'_weights.img'];
img4d = file_array(filename,[sample_img.dat.dim(1),sample_img.dat.dim(2),sample_img.dat.dim(3),n_folds],'float64-le',0,1,0);  

%Begin cross-validation loop
%-------------------------------------------------------------------------
for f = 1:n_folds
    
    fold  = C(:,f);
    train = fold == 2;
    
    img1d = prt_compute_weights(PRT.fs(ind_feat).ids(train),PRT.model(ind_model).output.fold(f));
    img3d = reshape(img1d,sample_img.dat.dim(1),sample_img.dat.dim(2),sample_img.dat.dim(3));
    img4d(:,:,:,f) = img3d;
    
end
    
 No         = sample_img; % copy header
 No.dat     = img4d;         % change file_array
 No.descrip = 'Pronto weigths';
 create(No);                 % write header
 
 
return