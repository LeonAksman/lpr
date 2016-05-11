function [outfile]=prt_cv_model(PRT,in)
% Function to run a cross-validation structure on a given model 
%
% Inputs:
% -------
% PRT:           data structure
% in.fname:      filename for PRT.mat (string)
% in.model_name: name for this model (string)
%
% Outputs:
% --------
% Writes the following fields in the PRT data structure:
% 
% PRT.model(m).output.fold(i).targets:     targets for fold(i)
% PRT.model(m).output.fold(i).predictions: predictions for fold(i)
% PRT.model(m).output.fold(i).stats:       statistics for fold(i)
% PRT.model(m).output.fold(i).{custom}:    optional fields
%
% Notes: 
% ------
% The PRT.model(m).input fields are set by prt_init_model, not by
% this function
%
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A Marquand 
% $Id: prt_cv_model.m 741 2013-07-22 14:07:36Z mjrosa $

prt_dir = char(regexprep(in.fname,'PRT.mat', ''));

% Get index of specified model
mid = prt_init_model(PRT, in);

% configure some variables
CV       = PRT.model(mid).input.cv_mat;     % CV matrix
n_folds  = size(CV,2);                      % number of CV folds
n_Phi    = length(PRT.model(mid).input.fs); % number of data matrices
samp_idx = PRT.model(mid).input.samp_idx;   % which samples are in the model

% targets
if isfield(PRT.model(mid).input,'include_allscans') && ...
   PRT.model(mid).input.include_allscans
    t = PRT.model(mid).input.targ_allscans;
else
    t = PRT.model(mid).input.targets;
end

% load data files and configure ID matrix
disp('Loading data files.....>>');
Phi_all = cell(1,n_Phi);
for i = 1:length(PRT.model(mid).input.fs)
    fid = prt_init_fs(PRT, PRT.model(mid).input.fs(i));
    
    if i == 1
        ID = PRT.fs(fid).id_mat(PRT.model(mid).input.samp_idx,:);
    end
        
    if PRT.model(mid).input.use_kernel
        load(fullfile(prt_dir, PRT.fs(fid).k_file));
        Phi_all{i} = Phi(samp_idx,samp_idx);
    else
        error('training with features not implemented yet');
        %vname = whos('-file', [prt_dir,PRT.fs(fid).fs_file]);
        %eval(['Phi_all{',num2str(i),'}=',vname,'(samp_idx,:);']);
    end
end

% Begin cross-validation loop
% -------------------------------------------------------------------------
PRT.model(mid).output.fold = struct();
for f = 1:n_folds
    disp ([' > running CV fold: ',num2str(f),' of ',num2str(n_folds),' ...'])
    % configure data structure for prt_cv_fold
    fdata.ID      = ID;
    fdata.mid     = mid;
    fdata.CV      = CV(:,f);
    fdata.Phi_all = Phi_all;
    fdata.t       = t;
    
    % compute the model for this CV fold
    [model, targets] = prt_cv_fold(PRT,fdata);
    
    %for classification check that for each fold, the test targets have been trained
    if strcmpi(PRT.model(mid).input.type,'classification')
        if ~all(ismember(unique(targets.test),unique(targets.train)))
            beep
            disp('At least one class is in the test set but not in the training set')
            disp('Abandoning modelling, please correct class selection/cross-validation')
            return
        end
    end
    
    % compute stats
    stats = prt_stats(model, targets.test, targets.train);
    
    % update PRT
    PRT.model(mid).output.fold(f).targets     = targets.test; 
    PRT.model(mid).output.fold(f).predictions = model.predictions(:);
    PRT.model(mid).output.fold(f).stats       = stats;
    % copy other fields from the model
    flds = fieldnames(model);
    for fld = 1:length(flds)
        fldnm = char(flds(fld));
        if ~strcmpi(fldnm,'predictions')
            PRT.model(mid).output.fold(f).(fldnm)=model.(fldnm);
        end
    end
end


% Model level statistics (across folds)
t             = vertcat(PRT.model(mid).output.fold(:).targets);
m.type        = PRT.model(mid).output.fold(1).type;
m.predictions = vertcat(PRT.model(mid).output.fold(:).predictions);
%m.func_val    = [PRT.model(mid).output.fold(:).func_val];
stats         = prt_stats(m,t(:),t(:));

PRT.model(mid).output.stats=stats;

% Save PRT containing machine output
% -------------------------------------------------------------------------
outfile = [prt_dir, 'PRT'];
disp('Updating PRT.mat.......>>')
if spm_matlab_version_chk('7') >= 0
    save(outfile,'-V6','PRT');
else
    save(outfile,'PRT');
end
end

