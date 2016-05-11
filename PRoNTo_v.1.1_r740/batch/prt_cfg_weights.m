function weights = prt_cfg_weights
% Preprocessing of the data.
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M.J.Rosa
% $Id: prt_cfg_weights.m 741 2013-07-22 14:07:36Z mjrosa $

% ---------------------------------------------------------------------
% filename Filename(s) of data
% ---------------------------------------------------------------------
infile        = cfg_files;
infile.tag    = 'infile';
infile.name   = 'Load PRT.mat';
infile.filter = 'mat';
infile.num    = [1 1];
infile.help   = {['Select PRT.mat (file containing data/design/models ',...
                 'structure).']};

% ---------------------------------------------------------------------
% model_name Feature set name
% ---------------------------------------------------------------------
model_name         = cfg_entry;
model_name.tag     = 'model_name';
model_name.name    = 'Model name';
model_name.help    = {'Name of a model. Must correspond with one ' ...
					  'specified in ''Run model'' and ''Specify model'''...
                      'batch modules.' };
model_name.strtype = 's';
model_name.num     = [1 Inf];

% ---------------------------------------------------------------------
% img_name Feature set name
% ---------------------------------------------------------------------
img_name         = cfg_entry;
img_name.tag     = 'img_name';
img_name.name    = 'Image name (optional)';
img_name.help    = {['Name of the file with weights (optional). If left empty ',...
                    ' an automatic name will be generated.']};
img_name.strtype = 's';
img_name.num     = [0 Inf];
img_name.val     = {''};

% ---------------------------------------------------------------------
% flag_cwi Build the weight images for each permutation (optional)
% ---------------------------------------------------------------------
flag_cwi         = cfg_menu;
flag_cwi.tag     = 'flag_cwi';
flag_cwi.name    = 'Build weight images for permutations';
flag_cwi.help    = {['Set to Yes to compute the weight images obtained ' ...
    'from each permutation. This is to further assess the significance ' ...
    'of the ranking distance between two models.']};
flag_cwi.labels  = {
               'Yes'
               'No'
}';
flag_cwi.values  = {1 0};
flag_cwi.val     = {0};

% ---------------------------------------------------------------------
% cv_model Preprocessing
% ---------------------------------------------------------------------
weights        = cfg_exbranch;
weights.tag    = 'weights';
weights.name   = 'Compute weights';
weights.val    = {infile model_name img_name flag_cwi};
weights.help   = {[
    'Compute weights. This module computes the linear weights of a classifier ',...
    'and saves them as a 4D image. 3 dimensions correspond to the image dimensions specified in ',...
    'the second-level mask, while the extra dimension corresponds to the number of folds. ',...
    'There is one 3D weights image per fold.']};
weights.prog   = @prt_run_weights;
weights.vout   = @vout_data;

%------------------------------------------------------------------------
%% Output function
%------------------------------------------------------------------------
function cdep = vout_data(job)
% Specifies the output from this modules, i.e. the filename of the mat file

cdep(1)            = cfg_dep;
cdep(1).sname      = 'PRT.mat file';
cdep(1).src_output = substruct('.','files');
cdep(1).tgt_spec   = cfg_findspec({{'filter','mat','strtype','e'}});
cdep(2)            = cfg_dep;
cdep(2).sname      = 'Weight image file';
cdep(2).src_output = substruct('.','files');
cdep(2).tgt_spec   = cfg_findspec({{'filter','img','strtype','e'}});
%------------------------------------------------------------------------
