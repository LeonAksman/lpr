function img_name = prt_compute_weights_class(PRT,in,model_idx,flag)
% FORMAT prt_compute_weights_class(PRT,in,model_idx)
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
% $Id: prt_compute_weights_class.m 741 2013-07-22 14:07:36Z mjrosa $

% Find machine
% -------------------------------------------------------------------------
mfunc       = PRT.model(model_idx).input.machine.function;
mname       = PRT.model(model_idx).model_name;
nclass      = length(PRT.model(model_idx).input.class);
if nclass > 2, mfunc = 'multiclass_machine'; end
m.args      = [];

% unfortunately a bug somewhere causes shifts in weight image if
% .nii is used...

switch mfunc
    
    case 'multiclass_machine'
        m.function  = 'prt_weights_gpclap';
        nclass      = length(PRT.model(model_idx).input.class);
        for c = 1:nclass
            img_mach{c} = ['weights_',mname,'_',num2str(c),'.img'];
        end
    case 'prt_machine_RT_bin'
        error('prt_compute_weights:MachineNotSupported',...
            'Error: weights computation not supported for this machine!');
    otherwise
        m.function  = 'prt_weights_bin_linkernel';
        img_mach{1} = ['weights_',mname,'.img'];
end

nimage = length(img_mach);
% Image name
% -------------------------------------------------------------------------
if ~isempty(in.img_name)
    if ~(prt_checkAlphaNumUnder(in.img_name))
        error('prt_compute_weights:NameNotAlphaNumeric',...
            'Error: image name should contain only alpha-numeric elements!');
    end
    for c = 1:nimage
        in.img_name_c  = [in.img_name,'_',num2str(c),'.img'];
        img_name{c}    = fullfile(in.pathdir,in.img_name_c);
    end
else
    for c = 1:nimage
        img_name{c}    = fullfile(in.pathdir,img_mach{c});
    end
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
idfeat = PRT.fas(fas_idx(1)).idfeat_img;
if ~isempty(PRT.fs(fs_idx).modality(mm).idfeat_fas)
    mask_train = idfeat(PRT.fs(fs_idx).modality(mm).idfeat_fas);
    voxtr = find(ismember(idfeat,mask_train));
else
    mask_train = idfeat;
    voxtr = 1:length(idfeat);
end

% Create image
% -------------------------------------------------------------------------

if flag
    %create images for each permutation
    if isfield(PRT.model(model_idx).output,'permutation')
        maxp = length(PRT.model(model_idx).output.permutation);
    else
        disp('No parameters saved for the permutation, building weight image only')
    end
else
    maxp=0;
end
pthperm = cell(nimage,1);
for p=0:maxp
    if p>0
        for c = 1:nimage
            [pth,nam] = fileparts(img_name{c});            
            if p==1
                pthperm{c} = fullfile(pth,['perm_',nam]);
                if ~exist(pthperm{c},'dir')
                    mkdir(pth,['perm_',nam]);
                end
            end            
            img_nam{c} = fullfile(pthperm{c},[nam,'_perm',num2str(p),'.img']);
        end
        fprintf('Permutation: %d of %d \n',p, ...
            length(PRT.model(model_idx).output.permutation));
    else
        img_nam = img_name;
    end
    
    % check that image does not exist, otherwise, delete
    if exist(img_nam{1},'file')
        for c = 1:nimage
            delete(img_nam{c});
            % delete hdr:
            [pth,nam] = fileparts(img_nam{c});
            hdr_name  = [pth,filesep,nam,'.hdr'];
            delete(hdr_name)
        end
    end
    
    hdr        = PRT.fas(fas_idx(1)).hdr.private;
    dat_dim    = hdr.dat.dim;
    
    if length(dat_dim)==2, dat_dim = [dat_dim 1]; end % handling case of 2D image
    
    img4d = cell(nimage,1); % afm
    for c = 1:nimage
        if p==0 %save folds for the 'true' image
            folds_comp=nfold+1;
        else    %save the average across folds only for permutations
            folds_comp=1;
        end
        img4d{c} = file_array(img_nam{c},[dat_dim(1),dat_dim(2),...
            dat_dim(3),folds_comp],'float32-le',0,1,0);
    end
    
    zdim    = dat_dim(3);
    xydim   = dat_dim(1)*dat_dim(2);
    % norm3d  = 0;
    
    disp('Computing weights.......>>')
    
    for z = 1:zdim
        
        fprintf('Slice: %d of %d \n',z,zdim);
        
        img3dav = cell(1,nimage);
        for c = 1:nimage
            img3dav{c}  = zeros(1,xydim); % average weight map
        end
        
        feat_slc = find(mask_train>=(xydim*(z-1)+1) & ...
            mask_train<=(xydim*z));
        
        if isempty(feat_slc)
            
            for c = 1:nimage
                img4d{c}(:,:,z,:) = NaN*zeros(dat_dim(1),dat_dim(2),1,folds_comp);
            end
            
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
                wimg      = prt_weights(d,m);
                
                for c = 1:nimage,
                    img3d              = zeros(1,xydim);
                    indi               = mask_train(feat_slc)-xydim*(z-1);
                    indm               = setdiff(1:xydim,indi);
                    img3d(indi)        = wimg{c};
                    norm3d{c}(f)       = sum(img3d.^2);
                    img3d(indm)        = NaN;
                    img3dav{c}         = img3dav{c} + img3d;
                    if p==0
                        img4d{c}(:,:,z,f)  = reshape(img3d,dat_dim(1),dat_dim(2),1,1);
                    end
                end
                
            end
            
            
            
            % Create average fold
            %------------------------------------------------------------------
            for c = 1:nimage
                norm4d{c}(z,:)             = norm3d{c};
                img3dav{c}                 = img3dav{c}/nfold; %afm
                img4d{c}(:,:,z,folds_comp) = reshape(img3dav{c},dat_dim(1),dat_dim(2),1,1); %afm
                norm4dav{c}(z,:)           = sum(img3dav{c}(isfinite(img3dav{c})).^2); %afm
            end
        end
        
    end
    
    for c =1:nimage
        norm4d{c}   = sqrt(sum(norm4d{c},1));
        norm4dav{c} = sqrt(sum(norm4dav{c},1)); %afm
    end
    
    disp('Normalising weights--------->>')
    if p==0
        for f = 1:nfold,
            for c = 1:nimage
                img4d{c}(:,:,:,f) = img4d{c}(:,:,:,f)./norm4d{c}(1,f);
            end
        end
    end
    
    for c = 1:nimage %afm
        img4d{c}(:,:,:,folds_comp) = img4d{c}(:,:,:,folds_comp)./norm4dav{c}; %afm
    end %afm
    
    % Create weigths file
    %-------------------------------------------------------------------------
    clear No
    for c = 1:nimage
        fprintf('Creating image %d of %d--------->>\n',c,nimage);
        No         = hdr;              % copy header
        No.dat     = img4d{c};         % change file_array
        No.descrip = 'Pronto weigths'; % description
        create(No);                    % write header
        disp('Done.')
    end
end

