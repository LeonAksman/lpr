function out = prt_run_weights(varargin)
%
% PRONTO job execution function
%
% INPUT
%   job    - harvested job data structure (see matlabbatch help)
%
% OUTPUT
%   out    - filename of saved data structure (1 file per group, per 
%            subject, per modality, per condition 
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by M.J.Rosa
% $Id: prt_run_weights.m 741 2013-07-22 14:07:36Z mjrosa $

job   = varargin{1};

% Load PRT.mat
% -------------------------------------------------------------------------
fname  = char(job.infile);
PRT=prt_load(fname);
if ~isempty(PRT)
    handles.dat=PRT;
else
    beep
    disp('Could not load file')
    return
end
pathdir = regexprep(fname,'PRT.mat', '');

% -------------------------------------------------------------------------
% Input file
% -------------------------------------------------------------------------
in.img_name   = job.img_name;
in.model_name = job.model_name;
in.pathdir    = pathdir;
if isfield(job,'flag_cwi')
    flag      = job.flag_cwi;
else
    flag      = 0;
end

img_name = prt_compute_weights(PRT, in, flag);

% -------------------------------------------------------------------------
% Function output
% -------------------------------------------------------------------------
disp('Weights computation complete.')
out.files{1} = fname;
out.files{2} = img_name;
disp('Done')

 return