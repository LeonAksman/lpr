function [PRT, CV, ID] = prt_model(PRT,in)
% Function to configure and build the PRT.model data structure
%
% Input:
% ------
%   PRT fields:
%   model.fs(f).fs_name:     feature set(s) this CV approach is defined for
%   model.fs(f).fs_features: feature selection mode ('all' or 'mask')
%   model.fs(f).mask_file:   mask for this feature set (fs_features='mask')
%
%   in.fname:      filename for PRT.mat
%   in.model_name: name for this cross-validation structure
%   in.type:       'classification' or 'regression'
%   in.use_kernel: does this model use kernels or features?
%   in.operations: operations to apply before prediction
%
%   in.fs(f).fs_name:     feature set(s) this CV approach is defined for
%
%   in.class(c).class_name
%   in.class(c).group(g).subj(s).num
%   in.class(c).group(g).subj(s).modality(m).mod_name
%   EITHER: in.class(c).group(g).subj(s).modality(m).conds(c).cond_name
%   OR:     in.class(c).group(g).subj(s).modality(m).all_scans
%   OR:     in.class(c).group(g).subj(s).modality(m).all_cond
%
%   in.cv.type:     type of cross-validation ('loso','losgo','custom')
%   in.cv.mat_file: file specifying CV matrix (if type='custom');
%
% Output:
% -------
%
%   This function performs the following functions:
%      1. populates basic fields in PRT.model(m).input
%      2. computes PRT.model(m).input.targets based on in.class(c)...
%      3. computes PRT.model(m).input.samp_idx based on targets
%      4. computes PRT.model(m).input.cv_mat based on the labels and CV spec
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand
% $Id: prt_model.m 741 2013-07-22 14:07:36Z mjrosa $

% Populate basic fields in PRT.mat
% -------------------------------------------------------------------------
[modelid, PRT] = prt_init_model(PRT,in);

% specify model type and feature sets
PRT.model(modelid).input.type = in.type;
if strcmp(in.type,'classification')
    for c = 1:length(in.class)
        PRT.model(modelid).input.class(c) = in.class(c);
    end
end

for f = 1:length(in.fs)
    fid = prt_init_fs(PRT,in.fs(f));
    
    if length(PRT.fs(fid).modality) > 1 && length(in.fs) > 1
        error('prt_model:multipleFeatureSetsAppliedAsSamplesAndAsFeatures',...
            ['Feature set ',in.fs(f).fs_name,' contains multiple modalities ',...
            'and job specifies that multiple feature sets should be ',...
            'supplied to the machine. This usage is not supported.']);
    end
    
    PRT.model(modelid).input.fs(f).fs_name = in.fs(f).fs_name;
end

% compute targets and samp_idx
% -------------------------------------------------------------------------
if strcmp(in.type,'classification')
    [targets, samp_idx, t_allscans, samp_allscans] = compute_targets(PRT, in);
else
    [targets, samp_idx, t_allscans] = compute_target_reg(PRT, in);
end
%[afm]
if isfield(in,'include_allscans') && in.include_allscans   
    PRT.model(modelid).input.samp_idx = samp_allscans;
    PRT.model(modelid).input.include_allscans = in.include_allscans;
else
    PRT.model(modelid).input.samp_idx = samp_idx;
    PRT.model(modelid).input.include_allscans = false;
end
PRT.model(modelid).input.targets          = targets;
PRT.model(modelid).input.targ_allscans    = t_allscans;

% compute cross-validation matrix and specify operations to apply
% -------------------------------------------------------------------------
    
[CV,ID] = compute_cv_mat(PRT,in, modelid);
PRT.model(modelid).input.cv_mat     = CV;
PRT.model(modelid).input.operations = in.operations;

% Added by Carlton
PRT.model(modelid).input.cv_type=in.cv.type;
% Save PRT.mat
% -------------------------------------------------------------------------
disp('Updating PRT.mat.......>>')
if spm_matlab_version_chk('7') >= 0
    save(in.fname,'-V7','PRT');
else
    save(in.fname,'-V6','PRT');
end

end

%% -------------------------------------------------------------------------
% Private Functions
% -------------------------------------------------------------------------

function [targets, samp_idx, t_all samp_all] = compute_targets(PRT, in)
% Function to compute the prediction targets. Also does some error checking

% Set the reference feature set
fid = prt_init_fs(PRT, in.fs(1));
ID  = PRT.fs(fid).id_mat;
n   = size(ID,1);

% Check the feature sets have the same number of samples (eg for MKL).
if length(in.fs) > 1
    for f = 1:length(in.fs)
        fid = prt_init_fs(PRT, in.fs(f));
        if size(PRT.fs(fid).id_mat,1) ~= n
            error('prt_model:sizeOfFeatureSetsDiffer',...
                ['Multiple feature sets included, but they have different ',...
                'numbers of samples']);
        end
    end
end

modalities = {PRT.masks(:).mod_name};
groups     = {PRT.group(:).gr_name};

t_all    = zeros(n,1);
samp_all = zeros(n,1);
for c = 1:length(in.class)
    
    % groups
    for g = 1:length(in.class(c).group)
        gr_name = in.class(c).group(g).gr_name;
        if any(strcmpi(gr_name,groups))
            gid = find(strcmpi(gr_name,groups));
        else
            error('prt_model:groupNotFoundInPRT',...
                ['Group ',gr_name,' not found in PRT.mat']);
        end
        
        % subjects
        for s = 1:length(in.class(c).group(g).subj)
            sid = in.class(c).group(g).subj(s).num;
            % modalities
            for m = 1:length(in.class(c).group(g).subj(s).modality)
                mod_name = in.class(c).group(g).subj(s).modality(m).mod_name;
                if any(strcmpi(mod_name,modalities))
                    mid = find(strcmpi(mod_name,modalities));
                else
                    error('prt_model:groupNotFoundInPRT',...
                        ['Modality ',mod_name,' not found in PRT.mat']);
                end
                
                if isfield(in.class(c).group(g).subj(s).modality(m), 'all_scans')
                    % check whether this was included in the feature set
                    % using 'all conditions' (which is invalid)
                    if strcmpi(PRT.fs(fid).modality(m).mode,'all_cond')
                        error('prt_model:fsIsAllCondModelisAllScans',...
                            ['''All scans'' selected for subject ',num2str(s),...
                            ', group ',num2str(g), ', modality ', num2str(m),...
                            ' but the feature set was constructed using ',...
                            '''All conditions''. This syntax is invalid. ',...
                            'Please use ''All Conditions'' instead.']);
                    end
                    
                    % otherwise add all scans for each subject
                    %[afm] idx = ID(:,1) == gid & ID(:,2) == s & ID(:,3) == mid;
                    idx = ID(:,1) == gid & ID(:,2) == sid & ID(:,3) == mid;
                    t_all(idx) = c;
                else % conditions have been specified
                    %[afm]sid = in.class(c).group(g).subj(s).num;
                    conds     = {PRT.group(gid).subject(sid).modality(mid).design.conds(:).cond_name};
                    
                    % check whether conditions were specified in the design
                    if ~isfield(PRT.group(gid).subject(sid).modality(mid).design,'conds')
                        error('prt_model:conditionsSpecifiedButNoneInDesign',...
                            ['Conditions selected for subject ',num2str(s),...
                            ', class ',num2str(c),', group ',num2str(g), ...
                            ', modality ', num2str(m),' but there are none in the design. ',...
                            'Please use ''All Scans'' or adjust design.']);
                    end
                    if isfield(in.class(c).group(g).subj(s).modality(m), 'all_cond')
                        % all conditions
                        for cid = 1:length(conds)
                            idx = ID(:,1) == gid & ID(:,2) == sid & ID(:,3) == mid & ID(:,4) == cid;
                            t_all(idx) = c;
                        end
                    else % loop over conditions
                        for cond = 1:length(in.class(c).group(g).subj(s).modality(m).conds)
                            cond_name = in.class(c).group(g).subj(s).modality(m).conds(cond).cond_name;
                            
                            if any(strcmpi(cond_name,conds))
                                cid = find(strcmpi(cond_name,conds));
                            else
                                error('prt_model:groupNotFoundInPRT',...
                                    ['Condition ',cond_name,' not found in PRT.mat']);
                            end
                            
                            idx = ID(:,1) == gid & ID(:,2) == sid & ID(:,3) == mid & ID(:,4) == cid;
                            t_all(idx) = c;
                        end
                    end
                    s_idx_mod = ID(:,1) == gid & ID(:,2) == sid & ID(:,3) == mid;
                    samp_all(s_idx_mod) = 1;
                end
            end
        end
    end
end

samp_idx = find(t_all);
samp_all = find(samp_all);
targets  = t_all(samp_idx);

end

function [CV,ID] = compute_cv_mat(PRT, in, modelid)
% Function to compute the cross-validation matrix. Also does error checking

fid = prt_init_fs(PRT, in.fs(1));
if isfield(in.cv,'k')
    k=in.cv.k;  %k-fold CV
else
    k=0; %loo cv
end
if k==1 %half-half
    k=2;
    flaghh=1;
else
    flaghh=0;
end
if isfield(in,'include_allscans') && in.include_allscans
    % use the full id matrix
    ID = PRT.fs(fid).id_mat;
else
    % id matrix only contains samples within the CV structure
    % it is initialised in prt_init_fs. The columns contents are described
    % in PRT.fs(fid).id_col_names
    % ('group','subject','modality','condition','block','scan')
    ID = PRT.fs(fid).id_mat(PRT.model(modelid).input.samp_idx,:);
end

switch in.cv.type
    case 'loso'
        % leave-one-subject-out
        % give each subject a unique id
        [gids,d1] = unique(ID(:,1), 'last');              
        [gids,d2] = unique(ID(:,1),'first');        
        gc = 0;
        ns=zeros(length(gids),1);
        for g = 1:length(gids)
            ns(g)=length(unique(ID(d2(g):d1(g),2)));
            gidx = ID(:,1) == gids(g);
            ID(gidx,2) = ID(gidx,2) + gc;
            gc = gc + ns(g);
        end
        % Compute CV matrix
        if k>1 %k-fold CV
            nsf=floor(gc/k);
            % Check that the number of folds does not exceed the number of
            % subjects
            if length(unique(ID(:,2)))<2*nsf
                error('prt_model:losoSelectedWithTooLargeK',...
                    'More than 50%% of data in testing set, reduce k');
            end
            mns=mod(gc,k);
            dk=nsf*ones(1,k);
            dk(end)=dk(end)+mns;
            inds=1;
            sk=[];
            for ii=1:length(dk)
                sk=[sk,inds*ones(1,dk(ii))];
                inds=inds+1;
            end
        else %Leave-One-Subject-Out
            sk=1:gc;
        end
        snums=[];
        for g = 1:length(gids)
            snums = [snums;histc(ID(d2(g):d1(g),2),unique(ID(d2(g):d1(g),2)))];
        end
        if length(snums) == 1
            error('prt_model:losoSelectedWithOneSubject',...
            'LOSO CV selected but only one subject is included');
        end
        G = cell(length(unique(sk)),1);
        for s = 1:length(unique(sk))
            G{s} = ones(sum(snums(sk==s)),1);
        end
        CV = blkdiag(G{:}) + 1;
        if flaghh
            CV=CV(:,1);
        end

        
    case 'losgo'
        %modify the ID to take the structure of the classes into account
        vcl=zeros(size(ID,1),2);
        for ic=1:length(in.class)
            nsg=1;
            for ig=1:length(in.class(ic).group)
                gnames={PRT.group(:).gr_name};
                [d,ng]=ismember(in.class(ic).group(ig).gr_name,gnames);
                for is=1:length(in.class(ic).group(ig).subj)
                    inds=find(ID(:,1)==ng);
                    indss=find(ID(inds,2)==is);
                    vcl(inds(indss),1)=ic;
                    vcl(inds(indss),2)=nsg;
                    nsg=nsg+1;
                end
            end
        end
        % leave-one-subject-per-group-out
        [gids,d1] = unique(vcl(:,1), 'last');
        [gids,d2] = unique(vcl(:,1),'first');
        %compute the number of subjects per class
        ns=zeros(length(gids),1);
        for ig= 1:length(gids)
            ns(ig)=length(unique(vcl(d2(ig):d1(ig),2)));
        end
        sids=max(ns);
        if sids == 1
            error('prt_model:losgoSelectedWithOneSubject',...
            'LOSGO CV selected but only one subject is included');
        end
        [nsf]=floor(min(ns/k));
        if k==0
            CV = zeros(size(ID,1),sids);
        else
            CV = zeros(size(ID,1),k);
        end
        if k>1 && nsf==1
            disp('Performing Leave-One Subject per Group-Out')
        end
        snums=[];
        for g=1:length(ns)
            is=vcl(:,1)==g;
            if k>1 && nsf>1 %k-fold CV
                nsfg=floor(ns(g)/k);
                if nsfg<1
                    error('prt_model:losgoSelectedWithTooLargeK',...
                        ['Number of subjects in group ',num2str(g),' smaller than k']);
                elseif nsfg*2>ns
                    error('prt_model:losgoSelectedWithTooLargeK2',...
                        ['Leaving more than 50%% of subjects in group ',num2str(g),' out']);
                end
                mns=mod(ns(g),nsfg);
                dk=nsfg*ones(1,floor(length(unique(vcl(is,2)))/nsfg));
                if mns>0
                    dk(end)=dk(end)+mns;
                end
                inds=1;
                sk=[];
                for ii=1:length(dk)
                    sk=[sk,inds*ones(1,dk(ii))];
                    inds=inds+1;
                end
            else %Leave-One-Subject per Group-Out
                sk=1:ns(g);
            end
            snums = histc(vcl(is,2),unique(vcl(is,2)));
            G = cell(length(unique(sk)),1);
            for s = 1:length(unique(sk))
                G{s} = ones(sum(snums(sk==s)),1);
            end
            CV(is,1:max(sk)) = blkdiag(G{:}) + 1;
            if length(unique(sk))<size(CV,2)  %smaller group, fill with 'train'
                CV(is,length(unique(sk))+1:size(CV,2))= ...
                    ones(length(find(is)),length(length(unique(sk))+1:size(CV,2)));
            end
            if flaghh
                CV=CV(:,1);
            end
        end
              
        
    case 'lobo'
        % leave-one-block-out - limited to one single subject for the
        % moment
        % blocks already have a unique ID
        if k>1 %k-fold CV
            nsf=floor(length(unique(ID(:,5)))/k);
            mns=mod(length(unique(ID(:,5))),k);
            dk=nsf*ones(1,k);
            dk(end)=dk(end)+mns;
            inds=1;
            sk=[];
            for ii=1:length(dk)
                sk=[sk,inds*ones(1,dk(ii))];
                inds=inds+1;
            end
        else %Leave-One-Subject-Out
            sk=1:max(ID(:,5));
            nsf=1;
        end
        snums = histc(ID(:,5),unique(ID(:,5)));% how many scans per block
        if length(snums) == 1
            error('prt_model:loboSelectedWithOneSubject',...
            'LOBO CV selected but only one block is included');
        elseif max(ID(:,5))< 2*nsf
            error('prt_model:loboSelectedWithLargeK',...
                'Leaving more than 50%% of blocks out, decrease k');
        end
        G = cell(length(unique(sk)),1);
        for s = 1:length(unique(sk))
            G{s} = ones(sum(snums(sk==s)),1);
        end
        CV = blkdiag(G{:}) + 1;
        if flaghh
            CV=CV(:,1);
        end
        
    case 'locbo'
        % leave-one-condition-per-block-out
        error('leave-one-condition-per-block-out not yet implemented');
        
    case 'loro'
        % leave-one-run-out
        
        mids = unique(ID(:,3));
        
        CV = zeros(size(ID,1),length(mids));
        for m = 1:length(mids)
            midx = ID(:,3) == mids(m);
            CV(:,m) = double(midx) + 1;
        end

    case 'custom'
        %load matrix and check that each fold contains test and train data.
        if isfield(in.cv,'mat_file') && ~isempty(in.cv.mat_file)
            load(in.cv.mat_file)
            if ~exist('CV')
                error('No CV variable found in the mat file provided')
            else
                if size(CV,1) ~= size(ID,1)
                    error('CV does not comprise the same number of samples as selected')
                else
                    nfo = size(CV,2);
                    macv = max(CV);
                    if length(find(macv==2)) ~= nfo %test data in all folds
                        error('One (or more) fold does not contain test data')
                    else
                        [i,j]=find(CV==1);
                        if length(unique(j)) ~= nfo %train data in all folds
                            error('One (or more) fold does not contain train data')
                        else
                            lv=CV>2;
                            sv=CV<0;
                            if any(any(lv)) || any(any(sv))
                                error('Values larger than 2 or smaller than 0 found in CV')
                            end
                        end
                    end
                end
            end
        elseif isfield(PRT.model(modelid).input,'cv_mat') && ...
                ~isempty(PRT.model(modelid).input.cv_mat) %custom CV specified by GUI
            CV=PRT.model(modelid).input.cv_mat;
        else
            %custom CV with only number of folds specified
            if isfield(in.cv,'k')
                CV = ones (size(ID,1),in.cv.k);
            end
                
        end
      
        
    otherwise
        error('prt_cv:unknownTypeSpecified',...
            ['Unknown type specified for CV structure (',in.type',')']);
end

end

function [targets, samp_idx, targ_allscans]=compute_target_reg(PRT, in)
% Function to compute the prediction targets. Not much error checking yet

% Set the reference feature set
fid = prt_init_fs(PRT, in.fs(1));
ID  = PRT.fs(fid).id_mat;
n   = size(ID,1);

modalities = {PRT.masks(:).mod_name};
groups     = {PRT.group(:).gr_name};
%t_all = zeros(n,1);
targ_allscans=zeros(n,1);
samp_idx=[];
targ_g=[];
for g = 1:length(in.group)
    gr_name = in.group(g).gr_name;
    if any(strcmpi(gr_name,groups))
        gid = find(strcmpi(gr_name,groups));
    else
        error('prt_model:groupNotFoundInPRT',...
            ['Group ',gr_name,' not found in PRT.mat']);
    end
    targets=zeros(length(in.group(g).subj),1);
    % subjects
    for s = 1:length(in.group(g).subj)
        % modalities, currently only one is allowed
        m=1;
        mod_name = in.group(g).subj(s).modality(m).mod_name;
        if any(strcmpi(mod_name,modalities))
            mid = find(strcmpi(mod_name,modalities));
        else
            error('prt_model:modalityNotFoundInPRT',...
                ['Modality ',mod_name,' not found in PRT.mat']);
        end
        idx = in.group(g).subj(s).num;
        targets(s) = PRT.group(gid).subject(idx).modality(mid).rt_subj;
        samp_idx=[samp_idx; find(ID(:,1) == gid & ID(:,2) == idx & ID(:,3) == mid)];
        
    end
    targ_g=[targ_g;targets];
end
targ_allscans(samp_idx)=targ_g;
targets=targ_g;
end
