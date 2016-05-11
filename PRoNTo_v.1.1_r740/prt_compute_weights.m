function img_name = prt_compute_weights(PRT,in,flag)
% FORMAT prt_compute_weights(PRT,in)
%
% This function calls prt_weights to compute weights 
% Inputs:
%       PRT             - data/design/model structure (it needs to contain
%                         at least one estimated model).
%       in              - structure with specific information to create
%                         weights
%           .model_name - model name (string)
%           .img_name   - (optional) name of the file to be created
%                         (string)
%           .pathdir    - directory path where to save weights (same as the
%                         one for PRT.mat) (string)
%       flag            - set to 1 to compute the weight images for each
%                         permutation (default: 0)
% Output:
%       img_name        - name of the .img file created
%       + image file created on disk
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M.J.Rosa
% $Id: prt_compute_weights.m 741 2013-07-22 14:07:36Z mjrosa $

% Find model
% -------------------------------------------------------------------------
nmodel = length(PRT.model);
model_idx = 0;
for i = 1:nmodel
    if strcmp(PRT.model(i).model_name,in.model_name)
        model_idx = i;
    end
end
% Check if model exists
if model_idx == 0, error('prt_compute_weights:ModelNotFound',...
        'Error: model not found in PRT.mat!'); end

mtype = PRT.model(model_idx).input.type;

% Chose weights function
% -------------------------------------------------------------------
switch mtype
    case 'classification'        
        img_name = prt_compute_weights_class(PRT,in,model_idx,flag);        
    case 'regression'       
        img_name = prt_compute_weights_regre(PRT,in,model_idx,flag);
end