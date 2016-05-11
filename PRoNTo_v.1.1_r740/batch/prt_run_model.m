function out = prt_run_model(varargin)
%
% PRoNTo job execution function
% takes a harvested job data structure and rearrange data into "proper"
% data structure, then save do what it has to do...
% Here simply the harvested job structure in a mat file.
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
%
% OUTPUT
%   out    - filename of saved data structure.
%
%   This function assembles a model structure with following fields:
%
%   model.fname:      filename for PRT.mat
%   model.model_name: name for this cross-validation structure
%   model.type:       'classification' or 'regression'
%   model.use_kernel: does this model use kernels or features?
%   model.operations: operations to apply before prediction
%
%   model.fs(f).fs_name:     feature set(s) this CV approach is defined for
%   model.fs(f).fs_features: feature selection mode ('all' or 'mask')
%   model.fs(f).mask_file:   mask for this feature set (fs_features='mask')
%
%   model.class(c).class_name
%   model.class(c).group(g).subj(s).num
%   model.class(c).group(g).subj(s).modality(m).mod_name
%   EITHER: model.class(c).group(g).subj(s).modality(m).conds(c).cond_name
%   OR:     model.class(c).group(g).subj(s).modality(m).all_scans
%   OR:     model.class(c).group(g).subj(s).modality(m).all_cond
%
%   model.cv.type:     type of cross-validation ('loso','losgo','custom')
%   model.cv.mat_file: file specifying CV matrix (if type = 'custom');
%
%   FIXME: add a more flexible interface for specifying custom CV
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand
% $Id: prt_run_model.m 741 2013-07-22 14:07:36Z mjrosa $

% Job variable
% -------------------------------------------------------------------------
job   = varargin{1};

% Load PRT.mat
% -------------------------------------------------------------------------
fname = char(job.infile);
if exist('PRT','var')
    clear PRT
end
PRT=prt_load(fname);
if ~isempty(PRT)
    handles.dat=PRT;
else
    beep
    disp('Could not load file')
    return
end

% assemble basic fields
model.fname      = fname;
model.model_name = job.model_name;
if ~(prt_checkAlphaNumUnder(model.model_name))
    beep
    disp('Model name should be entered in alphanumeric format only')
    disp('Please correct')
    return
end
model.use_kernel = job.use_kernel;

% insert feature set fields

model.fs(1).fs_name = job.fsets;
fid = prt_init_fs(PRT,model.fs(1));
mods = {PRT.fs(fid).modality(:).mod_name};

% get the conditions which are common to all subjects from all groups
nm = length(mods);
for i=1:nm
    flag=1;
    for j=1:length(PRT.group)
        for k=1:length(PRT.group(j).subject)
            m2= find(strcmpi(PRT.fs(fid).modality(nm).mod_name,mods));
            if isempty(m2)
                m2= find(strcmpi(PRT.fs(fid).modality(nm).mod_name,mods{1}));
            end
            des=PRT.group(j).subject(k).modality(m2).design;
            if isstruct(des) && flag
                if k==1 && j==1
                    lcond={des.conds(:).cond_name};
                else
                    tocmp={des.conds(:).cond_name};
                    lcond=intersect(lower(lcond),lower(tocmp));
                end
            else
                flag=0;
                lcond={};
            end
        end
    end
end
% Insert fields for generating the labels (ie. translate the fields coming
% from matlabbatch to something more consistent for the prt_model function)
% Note that we cycle through the groups to flatten out the structure, since
% we potentially specify multiple subjects per group
if isfield(job.model_type,'classification')
    model.type = 'classification';
    for c = 1:length(job.model_type.classification.class)
        model.class(c).class_name = job.model_type.classification.class(c).class_name;
        
        for g = 1:length(job.model_type.classification.class(c).group)
            scount = 1;
            model.class(c).group(g).gr_name = ...
                job.model_type.classification.class(c).group(g).gr_name;
            
            sids   = job.model_type.classification.class(c).group(g).subj_nums;
            for s = 1:length(sids)
                model.class(c).group(g).subj(scount).num = sids(s);
                for m = 1: length(mods)
                    model.class(c).group(g).subj(scount).modality(m).mod_name=mods{m};
                    if isfield(job.model_type.classification.class(c).group(g).conditions,'all_scans')
                        model.class(c).group(g).subj(scount).modality(m).all_scans = true;
                    elseif isfield(job.model_type.classification.class(c).group(g).conditions,'all_cond')
                        model.class(c).group(g).subj(scount).modality(m).all_cond = true;
                        if isempty(lcond)
                            beep
                            disp('All conditions selected while no conditions were common to all subjects')
                            disp('Please review the selection and/or the data and design')
                            return
                        end
                    else
                        model.class(c).group(g).subj(scount).modality(m).conds = ...
                            job.model_type.classification.class(c).group(g).conditions.conds;
                        for cc=1:length(job.model_type.classification.class(c).group(g).conditions.conds)
                            cname=job.model_type.classification.class(c).group(g).conditions.conds(cc).cond_name;
                            if isempty(intersect(lower({cname}),lower(lcond)))
                                beep
                                disp('This condition is not common to all subjects')
                                disp('Please remove it from the selection')
                                return
                            end
                        end
                    end
                end
                scount = scount+1;
            end
        end
    end
    % insert machine fields
    if isfield(job.model_type.classification.machine_cl,'svm')
        model.machine.function = 'prt_machine_svm_bin';
        model.machine.args     = job.model_type.classification.machine_cl.svm.svm_args;
    elseif isfield(job.model_type.classification.machine_cl,'gpc')
        model.machine.function='prt_machine_gpml';
        model.machine.args=job.model_type.classification.machine_cl.gpc.gpc_args;
    elseif isfield(job.model_type.classification.machine_cl,'gpclap')
        model.machine.function='prt_machine_gpclap';
        model.machine.args=job.model_type.classification.machine_cl.gpclap.gpclap_args;
    elseif isfield(job.model_type.classification.machine_cl,'rt')
        model.machine.function='prt_machine_RT_bin';
        model.machine.args=job.model_type.classification.machine_cl.rt.rt_args;
    else
        [pat, nam] = fileparts(char(job.model_type.classification.machine_cl.custom_machine.machine_func));
        model.machine.function = nam;
        model.machine.args = job.model_type.classification.machine_cl.custom_machine.machine_args;
    end

elseif isfield(job.model_type,'regression')
    model.type = 'regression';
    for g = 1:length(job.model_type.regression.reg_group)
        scount = 1;
        model.group(g).gr_name = job.model_type.regression.reg_group(g).gr_name;
        sids   =  job.model_type.regression.reg_group(g).subj_nums;
        for s = 1:length(sids)
            model.group(g).subj(scount).num = sids(s);
            model.group(g).subj(scount).modality.mod_name =  mods;
            scount=scount+1;
        end
    end
    
    if isfield(job.model_type.regression.machine_rg,'krr')
        model.machine.function='prt_machine_krr';
        model.machine.args=job.model_type.regression.machine_rg.krr.krr_args;
    elseif isfield(job.model_type.regression.machine_rg,'rvr')
        model.machine.function='prt_machine_rvr';
        model.machine.args=[];
    elseif isfield(job.model_type.regression.machine_rg,'gpr')
        model.machine.function='prt_machine_gpr';
        model.machine.args=job.model_type.regression.machine_rg.gpr.gpr_args;
    else
        [pat, nam] = fileparts(char(job.model_type.regression.machine_rg.custom_machine.machine_func));
        model.machine.function = nam;
        model.machine.args = job.model_type.regression.machine_rg.custom_machine.machine_args;
    end   
else
    error('this is not implemented yet');   
end

% assemble structure for performing cross-validation
if isfield(job.cv_type,'cv_loso')
    model.cv.type = 'loso';
    model.cv.k = 0;
elseif isfield(job.cv_type,'cv_lkso')
    model.cv.type = 'loso';
    model.cv.k = job.cv_type.cv_lkso.k_args;
elseif isfield(job.cv_type,'cv_losgo')
    model.cv.type = 'losgo';
    model.cv.k = 0;
elseif isfield(job.cv_type,'cv_lksgo')
    model.cv.type = 'losgo';
    model.cv.k = job.cv_type.cv_lksgo.k_args;
elseif isfield(job.cv_type,'cv_lobo') 
    model.cv.type = 'lobo';
    model.cv.k = 0;
elseif isfield(job.cv_type,'cv_lkbo')
    model.cv.type = 'lobo';
    model.cv.k = job.cv_type.cv_lkbo.k_args;
%     if scount>1
%         beep
%         disp('Leave One Block Out Cross Validation only allowed for within subject modeling')
%         disp('Please correct')
%     end
elseif isfield(job.cv_type,'cv_loro') %currently implemented for MCKR only
    model.cv.type = 'loro';
else
    model.cv.type     = 'custom';
    model.cv.mat_file = job.cv_type;
end

model.include_allscans = job.include_allscans;

% specify operations to apply to the data prior to prediction
% if isfield(job.data_ops,'data_ops')
%     model.operations = [job.data_ops.sel_ops.data_op{:}];
% elseif isfield(job.data_ops,'no_op')
%     model.operations = [];
% end
if isfield(job.sel_ops.use_other_ops,'data_op')
    ops = [job.sel_ops.use_other_ops.data_op{:}];
elseif isfield(job.sel_ops.use_other_ops,'no_op')
    ops = [];
end
if job.sel_ops.data_op_mc == 0
    model.operations = [3 ops];
else
    model.operations = ops;
end

prt_model(PRT,model);

% Function output
% -------------------------------------------------------------------------
out.files{1} = fname;
out.mname = model.model_name;
disp('Model configuration complete.')
end
