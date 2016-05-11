function [outfile] = prt_fs(PRT,in)
% Function to build file arrays containing the (linearly detrended) data
% and compute a linear (dot product) kernel from them
%
% Inputs:
% -------
% in.fname:      filename for the PRT.mat (string)
% in.fs_name:    name of fs and relative path filename for the kernel matrix
%
% in.mod(m).mod_name:  name of modality to include in this kernel (string)
% in.mod(m).detrend:   detrend (scalar: 0 = none, 1 = linear)
% in.mod(m).param_dt:  parameters for the kernel detrend (e.g. DCT bases)
% in.mod(m).mode:      'all_cond' or 'all_scans' (string)
% in.mod(m).mask:      mask file used to create the kernel
% in.mod(m).normalise: 0 = none, 1 = normalise_kernel, 2 = scale modality
% in.mod(m).matnorm:   filename for scaling matrix
%
% Outputs:
% --------
% Calls prt_init_fs to populate basic fields in PRT.fs(f)...
% Writes PRT.mat
% Writes the kernel matrix to the path indicated by in.fs_name
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand and J. Schrouff
% $Id: prt_fs.m 741 2013-07-22 14:07:36Z mjrosa $

% Configure some variables and get defaults
% -------------------------------------------------------------------------
prt_dir  = regexprep(in.fname,'PRT.mat', ''); % or: fileparts(fname);
n_groups = length(PRT.group);

% get the index of the modalities for which the user wants a kernel/data
n_mods=length(in.mod);
mids=[];
for i=1:n_mods
    if ~isempty(in.mod(i).mod_name)
        mids = [mids, i];
    end
end
n_mods=length(mids);
def=prt_get_defaults('fs');

% Load mask(s) and resize if necessary
[mask,precmask,headers,PRT] = load_masks(PRT, prt_dir, in,mids);

% Initialize the file arrays, kernel and feature set parameters
[fid,PRT,tocomp] = prt_init_fs(PRT,in,mids,mask,precmask,headers);

% -------------------------------------------------------------------------
% ---------------------Build file arrays and kernel------------------------
% -------------------------------------------------------------------------

% set memory limit
nfa = [];
for m = 1:n_mods
    nfa   = [nfa, PRT.fas(mids(m)).dat.dim(1)];
    if tocomp(mids(m))        
        n_vox = PRT.fas(mids(m)).dat.dim(2); %n_vox has to be the same for all concatenated modalities (version 1.1)
    else
        n_vox = numel(PRT.fs(fid).modality(m).idfeat_fas);
    end
end

n           = length(PRT.fs(fid).id_mat);

%LEON ADDED 5/12/2013
bStackScansMode         = false;
if bStackScansMode
    numScansPerSubject 	= length(unique(PRT.fs.id_mat(:, 6)));
    Phi                 = zeros(n/numScansPerSubject);
else
    Phi                 = zeros(n);
end


mem         = def.mem_limit;
block_size  = floor(mem/(8*3)/max([nfa, n])); % Block size (double = 8 bytes)
n_block     = ceil(n_vox/block_size);

bstart = 1; bend = min(block_size,n_vox);
h = waitbar(0,'Please wait while preparing feature set');
step=1;
for b = 1:n_block
    disp ([' > preparing block: ', num2str(b),' of ',num2str(n_block),' ...'])
    vox_range  = bstart:bend;
    block_size = length(vox_range);
    kern_vols  = zeros(block_size,n);
    for m=1:n_mods
        mid=mids(m);
        %Parameters for the masks and indexes of the voxels
        %-------------------------------------------------------------------
        % get the indices of the voxels within the file array mask (data &
        % design step)
        ind_ddmask = PRT.fas(mid).idfeat_img(vox_range);
        
        %load the mask for that modality if another one was specified
        if ~isempty(precmask{m})
            prec_mask = prt_load_blocks(precmask{m},ind_ddmask);
        else
            prec_mask = ones(block_size,1);
        end
        %indexes to access the file array
        indm = find(PRT.fs(fid).fas.im==mid);
        ifa  = PRT.fs(fid).fas.ifa(indm);
        %get the data from each subject of each group and save its linear
        %detrended version in a file array
        %-------------------------------------------------------------------
        if tocomp(mid)  %need to build the file array corresponding to that modality
            sample_range=0;
            nfa=PRT.fas(mid).dat.dim(1);
            datapr=zeros(block_size,nfa);
            
            %get the data for each subject of each group
            for gid = 1:n_groups
                for sid = 1:length(PRT.group(gid).subject)
                    n_vols_s = size(PRT.group(gid).subject(sid).modality(mid).scans,1);
                    sample_range = (1:n_vols_s)+max(sample_range);
                    fname = PRT.group(gid).subject(sid).modality(mid).scans;
                    datapr(:,sample_range) = prt_load_blocks(fname,ind_ddmask);
                    %check for NaNs, in case of beta maps                  
                    [inan,jnan] = find(isnan(datapr(:,sample_range)));
                    if ~isempty(inan)
                        for inn=1:length(inan)
                            datapr(inan(inn),sample_range(jnan(inn))) = 0;
                        end
                    end
                    
                    %detrend if necessary
                    if in.mod(mid).detrend ~= 0
                        if  isfield(PRT.group(gid).subject(sid).modality(mid).design,'TR')
                            TR = PRT.group(gid).subject(sid).modality(mid).design.TR;
                        else
                            try
                                TR = PRT.group(gid).subject(sid).modality(mid).TR;
                            catch
                                error('detrend:TRnotfound','No TR in data, suggesting that detrend is not necessary')
                            end
                        end
                        switch in.mod(mid).detrend
                            case 1
                                C = poly_regressor(length(sample_range), ...
                                        in.mod(mid).param_dt);
                            case 2
                                C = dct_regressor(length(sample_range), ...
                                        in.mod(mid).param_dt,TR);
                        end
                        R = eye(length(sample_range)) - C*pinv(C);
                        datapr(:,sample_range) = datapr(:,sample_range)*R';
                    end
                end
            end
            
            if b==1
                % Write the detrended data into the file array .dat
                namedat=['Feature_set_',char(in.mod(mid).mod_name),'.dat'];
                fpd_clean(m) = fopen(fullfile(prt_dir,namedat), 'w','ieee-le'); %#ok<AGROW> % 'a' append
                fwrite(fpd_clean(m), datapr', 'float32',0,'ieee-le');
            else
                % Append the data in file .dat
                fwrite(fpd_clean(m), datapr', 'float32',0,'ieee-le');
            end
            
            % get the data to build the kernel
            kern_vols(:,indm) = datapr(:,ifa).* ...
                repmat(prec_mask~=0,1,length(ifa));
            % if a scaling was entered, apply it now
            if ~isempty(PRT.fs(fid).modality(m).normalise.scaling)
                kern_vols(:,indm) = kern_vols(:,indm)./ ...
                    repmat(PRT.fs(fid).modality(m).normalise.scaling,block_size,1);
            end
            clear datapr
        else
            idf=PRT.fs(fid).modality(m).idfeat_fas;
            kern_vols(:,indm) = (PRT.fas(mid).dat(ifa,idf(vox_range)))';
            %old version
%             kern_vols(:,indm) = (PRT.fas(mid).dat(ifa,vox_range))' .*...
%                 repmat(prec_mask~=0,1,length(ifa));
            % if a scaling was entered, apply it now
            if ~isempty(PRT.fs(fid).modality(m).normalise.scaling)
                kern_vols(:,indm) = kern_vols(:,indm)./ ...
                    repmat(PRT.fs(fid).modality(m).normalise.scaling,block_size,1);
            end
            
        end
        waitbar(step/ (n_block*n_mods),h);
        step=step+1;
    end
    if size(kern_vols,2)>6e3
        % Slower way of estimating kernel but using less memory.
        % size limit setup such that no more than ~1Gb of mem is required:
        % 1Gb/3(nr of matrices)/8(double)= ~40e6 -> sqrt -> 6e3 element
        for ic=1:size(kern_vols,2)
            Phi(:,ic) = Phi(:,ic) + kern_vols' * kern_vols(:,ic);
        end
    else
        
        %LEON CHANGED 12/5/2013
        if bStackScansMode
            kern_vols_stacked       = []; 
            for i = 1:numScansPerSubject
                kern_vols_i         = kern_vols(:, i:numScansPerSubject:end);                
                kern_vols_stacked   = [kern_vols_stacked; kern_vols_i];
            end
            Phi                     = Phi + (kern_vols_stacked' * kern_vols_stacked);             
        else        
            Phi                     = Phi + (kern_vols' * kern_vols);
        end
        %Phi = Phi + (kern_vols' * kern_vols);
    end
    bstart = bend+1; bend = min(bstart+block_size-1,n_vox);
    clear block_mask kern_vols
end
close(h)

% closing feature file(s)
if exist('fpd_clean','var')
    for ii=1:numel(fpd_clean)
        fclose(fpd_clean(ii));
    end
end

if bStackScansMode
    indexFirstScan          = find(PRT.fs(fid).id_mat(:, 6) == 1);
    PRT.fs(fid).id_mat      = PRT.fs(fid).id_mat(indexFirstScan, :);
end

% Save kernel and function output
% -------------------------------------------------------------------------
outfile = in.fname;
disp('Saving feature set to: PRT.mat.......>>')
disp(['Saving kernel to: ',in.fs_name,'.mat.......>>'])
fs_file = [prt_dir,in.fs_name];
if spm_matlab_version_chk('7') >= 0
    save(outfile,'-V6','PRT');
    save(fs_file,'-V6','Phi');
else
    save(outfile,'PRT');
    save(fs_file,'Phi');
end
disp('Done.')

% -------------------------------------------------------------------------
% Private functions
% -------------------------------------------------------------------------
function [mask, precmask, headers,PRT] = load_masks(PRT, prt_dir, in, mids)
% function to load the mask for each modality
% -------------------------------------------
n_mods   = length(mids);
mask     = cell(1,n_mods);
precmask = cell(1,n_mods);
headers  = cell(1,n_mods);
for m = 1:n_mods
    mid = mids(m);
    
    % get mask for the within-brain voxels (from data and design)
    ddmask = PRT.masks(mid).fname;
    try
        M = nifti(ddmask);
    catch %#ok<*CTCH>
        error('prt_prepare_data:CouldNotLoadFile',...
            'Could not load mask file');
    end
    
    % get mask for the kernel if one was specified
    mfile = in.mod(mid).mask;
    if ~isempty(mfile) %&&  mfile ~= 0
        try
            precM = spm_vol(char(mfile));
        catch
            error('prt_prepare_data:CouldNotLoadFile',...
                'Could not load mask file for preprocessing');
        end
    end
    
    % get header of the first scan of that modality
    if isfield(PRT,'fas') && mid<=length(PRT.fas) && ...
            ~isempty(PRT.fas(mid).dat)
        N = PRT.fas(mid).hdr;
    else
        N = spm_vol(PRT.group(1).subject(1).modality(mid).scans(1,:));
    end
    headers{m}=N;
    
    % compute voxel dimensions and check for equality if n_mod > 1
    if m == 1
        n_vox = prod(N.dim(1:3));
    elseif n_mods > 1 && n_vox ~= prod(N.dim(1:3))
        error('prt_prepare_data:multipleModatlitiesVariableFeatures',...
            'Multiple modalities specified, but have variable numbers of features');
    end
    
    % resize the different masks if needed
    if N.dim(3)==1, Npdim = N.dim(1:2); else Npdim = N.dim; end % handling case of 2D images
    if any(size(M.dat(:,:,:,1)) ~= Npdim)
        warning('prt_prepare_data:maskAndImagesDifferentDim',...
            'Mask has different dimensions to the image files. Resizing...');
        
        V2 = spm_vol(char(ddmask));
        % reslicing V2        
        fl_res = struct('mean',false,'interp',0,'which',1,'prefix','tmp_');
        spm_reslice([N V2],fl_res)
        % now renaming the file 
        [V2_pth,V2_fn,V2_ext] = spm_fileparts(V2.fname);
        rV2_fn = [fl_res.prefix,V2_fn];
        if strcmp(V2_ext,'.nii')
            % turn .nii into .img/.hdr image!
            V_in = spm_vol(fullfile(V2_pth,[rV2_fn,'.nii']));
            V_out = V_in; V_out.fname = fullfile(V2_pth,[rV2_fn,'.img']);
            spm_imcalc(V_in,V_out,'i1');
        end
        mfile_new = ['updated_1stlevel_mask_m',num2str(mid)];
        movefile(fullfile(V2_pth,[rV2_fn,'.img']), ...
                    fullfile(prt_dir,[mfile_new,'.img']));
        movefile(fullfile(V2_pth,[rV2_fn,'.hdr']), ...
                    fullfile(prt_dir,[mfile_new,'.hdr']));
        PRT.masks(mid).fname = fullfile(prt_dir,[mfile_new,'.img']);
        mask{m} = PRT.masks(mid).fname;        
    else
        mask{m} = ddmask;        
    end
    if ~isempty(mfile) && any((precM.dim~= N.dim)) % && mfile ~= 0 
        warning('prt_prepare_data:maskAndImagesDifferentDim',...
            'Preprocessing mask has different dimensions to the image files. Resizing...');      
        V2 = spm_vol(char(mfile));
        % reslicing V2        
        fl_res = struct('mean',false,'interp',0,'which',1,'prefix','tmp_');
        spm_reslice([N V2],fl_res)
        % now renaming the file 
        [V2_pth,V2_fn,V2_ext] = spm_fileparts(V2.fname);
        rV2_fn = [fl_res.prefix,V2_fn];
        if strcmp(V2_ext,'.nii')
            % turn .nii into .img/.hdr image!
            V_in = spm_vol(fullfile(V2_pth,[rV2_fn,'.nii']));
            V_out = V_in; V_out.fname = fullfile(V2_pth,[rV2_fn,'.img']);
            spm_imcalc(V_in,V_out,'i1');
        end
        % if more than one 2nd level mask to resize
        nummask = 1;
        while exist(fullfile( ...
                    prt_dir,['updated_2ndlevel_mask_m',num2str(mid),'_',...
                    num2str(nummask),'.img']),'file')
                nummask = nummask+1;
        end
        mfile_new = ['updated_2ndlevel_mask_m',num2str(mid),...
            '_',num2str(nummask)];
        movefile(fullfile(V2_pth,[rV2_fn,'.img']), ...
                    fullfile(prt_dir,[mfile_new,'.img']));
        movefile(fullfile(V2_pth,[rV2_fn,'.hdr']), ...
                    fullfile(prt_dir,[mfile_new,'.hdr']));
        precmask{m} = fullfile(prt_dir,[mfile_new,'.img']);
    else
        precmask{m} = mfile;
    end
    clear M N precM V1 V2 mfile mfile_new
end
return

function c = poly_regressor(n,order)
% n:     length of the series
% order: the order of polynomial function to fit the tend

basis = repmat([1:n]',[1 order]);
o = repmat([1:order],[n 1]);
c = [ones(n,1) basis.^o];
return

function c=dct_regressor(n,cut_off,TR)
% n:       length of the series
% cut_off: the cut off perioed in second (1/ cut off frequency)
% TR:      TR

if cut_off<0
    error('cut off cannot be negative')
end

T = n*TR;
order = floor((T/cut_off)*2)+1;
c = spm_dctmtx(n,order);
return
