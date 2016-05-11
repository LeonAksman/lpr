function img_name = prt_compute_weights_regre(PRT,in,model_idx,flag)
% FORMAT prt_compute_weights_regre(PRT,in,model_idx)
%
% This function calls prt_weights to compute weights
% Inputs:
%       PRT             - data/design/model structure (it needs to contain
%                         at least one estimated model).
%         in            - structure with specific information to create
%                         weights
%           .model_name - model name (string)
%           .img_name   - (optional) name of the file to be created
%                         (string)
%           .pathdir    - directory path where to save weights (same as the
%                         one for PRT.mat) (string)
%         model_idx     - model index (integer)
%         flag          - compute weight images for each permutation if 1
% Output:
%       img_name        - name of the .img file created
%       + image file created on disk
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M.J.Rosa
% $Id: prt_compute_weights_regre.m 741 2013-07-22 14:07:36Z mjrosa $

% Find machine
% -------------------------------------------------------------------------
mname       = PRT.model(model_idx).model_name;
m.args      = [];

% unfortunately a bug somewhere causes shifts in weight image if
% .nii is used...

m.function  = 'prt_weights_bin_linkernel';
img_mach    = ['weights_',mname,'_1.img'];

% Image name
% -------------------------------------------------------------------------
if ~isempty(in.img_name)
    if ~(prt_checkAlphaNumUnder(in.img_name))
        error('prt_compute_weights:NameNotAlphaNumeric',...
            'Error: image name should contain only alpha-numeric elements!');
    end
    in.img_name_c  = [in.img_name,'.img'];
    img_name       = fullfile(in.pathdir,in.img_name_c);
else
    img_name       = fullfile(in.pathdir,img_mach);
end


% Other info
% -------------------------------------------------------------------------
fs_name  = PRT.model(model_idx).input.fs(1).fs_name;
samp_idx = PRT.model(model_idx).input.samp_idx;
nfold    = length(PRT.model(model_idx).output.fold);

% Find feature set
% -------------------------------------------------------------------------
nfs = length(PRT.fs);
for f = 1:nfs
    if strcmp(PRT.fs(f).fs_name,fs_name)
        fs_idx = f;
    end
end
ID     = PRT.fs(fs_idx).id_mat(PRT.model(model_idx).input.samp_idx,:);
ID_all = PRT.fs(fs_idx).id_mat;

% Find modality
% -------------------------------------------------------------------------
nfas = length(PRT.fas);
mods = {PRT.fs(fs_idx).modality.mod_name};
fas  = zeros(1,nfas);
for i = 1:nfas
    for j = 1:length(mods)
        if strcmpi(PRT.fas(i).mod_name,mods{j})
            fas(i) = 1;
            mm=j;
        end
    end
end
fas_idx = find(fas);

% Get the indexes of the voxels which are in the second level mask
% -------------------------------------------------------------------------
idfeat=PRT.fas(fas_idx(1)).idfeat_img;
if ~isempty(PRT.fs(fs_idx).modality(mm).idfeat_fas)
    mask_train=idfeat(PRT.fs(fs_idx).modality(mm).idfeat_fas);
    voxtr=find(ismember(idfeat,mask_train));
else
    mask_train=idfeat;
    voxtr=1:length(idfeat);
end

% Create image
% -------------------------------------------------------------------------

if flag
    %create images for each permutation
    if isfield(PRT.model(model_idx).output,'permutation')
        maxp=length(PRT.model(model_idx).output.permutation);
    else
        disp('No parameters saved for the permutation, building weight image only')
    end
else
    maxp=0;
end

for p=0:maxp
    if p>0
        [pth,nam] = fileparts(img_name);
        [d1,d2]   = fileparts(img_mach);
        if p==1
            pthperm=[pth,filesep,['perm_',d2]];
            if ~exist(pthperm,'dir')
                mkdir(pth,['perm_',d2]);
            end
        end
        img_nam=[pthperm,filesep,nam,'_perm',num2str(p),'.img'];
        fprintf('Permutation: %d of %d \n',p,length(PRT.model(model_idx).output.permutation));
    else
        img_nam=img_name;
    end
    
    %check that image does not exist, otherwise, delete
    if exist(img_nam,'file')
        delete(img_nam);
        %delete hdr:
        [pth,nam] = fileparts(img_nam);
        hdr_name  = [pth,filesep,nam,'.hdr'];
        delete(hdr_name)
    end
    
    hdr        = PRT.fas(fas_idx(1)).hdr.private;
    dat_dim    = hdr.dat.dim;
    
    if length(dat_dim)==2, dat_dim = [dat_dim 1]; end % handling case of 2D image
    
    if p==0 %save folds for the 'true' image
        folds_comp=nfold+1;
    else    %save the average across folds only for permutations
        folds_comp=1;
    end
    img4d      = file_array(img_nam,[dat_dim(1),dat_dim(2),...
        dat_dim(3),folds_comp],'float32-le',0,1,0);
    
    zdim    = dat_dim(3);
    xydim   = dat_dim(1)*dat_dim(2);
    % norm3d  = 0;
    
    disp('Computing weights.......>>')
    
    for z = 1:zdim
        
        fprintf('Slice: %d of %d \n',z,zdim);
        
        img3dav  = zeros(1,xydim); % average weight map
        
        feat_slc = find(mask_train>=(xydim*(z-1)+1) & ...
            mask_train<=(xydim*z));
        
        if isempty(feat_slc)
            
            img4d(:,:,z,:) = NaN*zeros(dat_dim(1),dat_dim(2),1,folds_comp);
        else
            
            for f = 1:nfold
                
                train_idx      = PRT.model(model_idx).input.cv_mat(:,f)==1;
                train          = samp_idx(train_idx);
                train_all      = zeros(size(ID_all,1),1); train_all(train) = 1;
                
                if p>0
                    d.coeffs   = PRT.model(model_idx).output.permutation(p).fold(f).alpha;
                else
                    d.coeffs   = PRT.model(model_idx).output.fold(f).alpha;
                end
                
                d.datamat = zeros(length(train), length(feat_slc));
                for i = 1:length(fas_idx)
                    % indexes to access the file array
                    indm = PRT.fs(fs_idx).fas.im == fas_idx(i) & train_all;
                    ifa  = PRT.fs(fs_idx).fas.ifa(indm);
                    
                    % index for the target data matrix
                    indtr = ID(train_idx,3) == fas_idx(i);
                    d.datamat(indtr,:) = PRT.fas(fas_idx(i)).dat(ifa,voxtr(feat_slc));
                end
                
                % Apply any operations specified during training
                ops = PRT.model(model_idx).input.operations(PRT.model(model_idx).input.operations ~=0 );
                cvdata.train      = {d.datamat};
                cvdata.tr_id      = ID(train_idx,:);
                cvdata.use_kernel = false; % need to apply the operation to the data
                for o = 1:length(ops)
                    cvdata = prt_apply_operation(PRT, cvdata, ops(o));
                end
                d.datamat = cvdata.train{:};
                
                % COMPUTE WEIGHTS
                wimg               = prt_weights(d,m);
                
                img3d              = zeros(1,xydim);
                indi               = mask_train(feat_slc)-xydim*(z-1);
                indm               = setdiff(1:xydim,indi);
                img3d(indi)        = wimg{1};
                norm3d(f)          = sum(img3d.^2);
                img3d(indm)        = NaN;
                img3dav            = img3dav + img3d;
                if p==0
                    img4d(:,:,z,f)     = reshape(img3d,dat_dim(1),dat_dim(2),1,1);
                end
                
            end
            
            
            
            % Create average fold
            %------------------------------------------------------------------
            norm4d(z,:)          = norm3d;
            img4d(:,:,z,folds_comp) = reshape(img3dav,dat_dim(1),dat_dim(2),...
                1,1)/nfold;
        end
        
    end
    
    norm4d = sqrt(sum(norm4d,1));
    if p==0
        disp('Normalising weights--------->>')
        for f = 1:nfold,
            img4d(:,:,:,f) = img4d(:,:,:,f)./norm4d(1,f);
        end
    end
    
    % Create weigths file
    %-------------------------------------------------------------------------
    fprintf('Creating image --------->>\n');
    No         = hdr;              % copy header
    No.dat     = img4d;            % change file_array
    No.descrip = 'Pronto weigths'; % description
    create(No);                    % write header
end
disp('Done.')

