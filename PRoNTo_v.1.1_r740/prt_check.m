function ok = prt_check(list_check,dir_root)
% Function to automatically test PRoNTo's integrity
%
% The goal is to have PRoNTo run through typical analysis and check if the
% calculations proceed smoothly.
% This relies on pre-specified 
% - organisation of data in subdirectories
% - batches with all the operations, in a .mat file with now location
% 
% Data sets considered, in this *specific order*:
% 1. "Haxby" - Haxby data, single subject, fmri 
% 2. "IXI"   - IXI data, multi subject, divergence & momentum maps
% 3. "Faces" - SPM's famous-vs-nonfamous faces data, multi subject.
%
% See the subfunctions for a detailed description of the tests performed.
%
% FORMAT ok = prt_check(list_check,dir_root)
%
% INPUT
%   list_check  - list of data sets to use
%   dir_root    - root directory of data sets
%
% OUTPUT:
%   ok          - vector of output (1='ok', 0='failed', -1='not tested')
%
% NOTE:
% - For a more automatic testing on your own system, then up date the
%   default 'dir_root' variable with the path to the 'PRoNTo_data'
%   directory on your system.
% - This will close all Matlab windows before relaunching PRoNTo and the
%   matlabbatch system.
% - Need to include the RandomForest classification for a more complete 
%   check, when available and working. Simple case could be to use RF on 
%   the Faces data set.
%_______________________________________________________________________
% Copyright (C) 2012 Machine Learning & Neuroimaging Laboratory

% Written by Christophe Phillips, CRC, ULg, Belgium.
% $Id: prt_check.m 741 2013-07-22 14:07:36Z mjrosa $

% Defining the check parameters.
% data sets, list to check and root directory
%--------------------------------------------
% list here the ones you want to check, e.g. 'list_check = 1:3;' for all
if nargin<1, list_check = [1 2 3]; end
if nargin<2
     % adjust with your own data set
    dir_root = 'D:\3_Data\PRoNTo\PRoNTo_data'; 
end
while isempty(dir_root) || ~exist(dir_root,'dir')
    % or select the root directories manually
    dir_root = spm_select([1 1],'dir','Select root dir for data sets');
end
dat_name = {'Haxby' , 'IXI ' , 'Faces'};
Ndat = numel(dat_name);
data_dir = cell(Ndat,1);
for ii=1:Ndat
    data_dir{ii} = fullfile(dir_root,deblank(dat_name{ii}));
end

% Clearing Matlab then setting up PRONTO and the batch system
%------------------------------------------------------------
 close all
 prt_batch
 
% Going through the various tests
%--------------------------------
ok = zeros(Ndat,1)-1;
for ii=list_check
    switch ii
        case 1 % Haxby data
            ok(ii) = check_Haxby(data_dir{ii});
        case 2 % IXI data
            ok(ii) = check_IXI(data_dir{ii});
        case 3 % famous-vs-nonfamous data
            ok(ii) = check_FvsNF(data_dir{ii});
        otherwise
            fprintf(1,'\nUNKNOWN DATA SET TO CHECK!\n') %#ok<*PRTCAL>
            beep
    end
end

% Printing out the results
%-------------------------
fprintf('\nTesting on data sets:\n')
for ii=1:Ndat
    switch ok(ii)
        case -1, msg = 'not tested';
        case 0 , msg = 'failed';
        case 1 , msg = 'passed';
        otherwise, msg = 'unknown output flag';
    end
    fprintf('\t%s\t: %s\n',dat_name{ii},msg);
end

end

%==========================================================================
%% INDIVIDUAL DATA SET CHECKING ROUTINES
%==========================================================================

%% HAXBY data set
function ok = check_Haxby(rdata_dir)
%
% This batch will go through the following modules, as saved in the
% batch_test_HaxbyData.mat file:
% - 'File selector' for (1) images, (2) SPM.mat, (3) mask 1st level, and
%   (4) mask 2nd level
% - 'Directory selector' for the root of the data directory
% - 'Make directory', create 'test_results' directory at the root of the 
%   data directory
% - 'Data & design' as in manual example with whole brain mask
% - 'Feature set', as in manual example, no 2nd level mask
% - 'Specify model', as in manual example, svm Faces vs Houses but with a
%   k-folds CV on blocks (k=4)
% - 'Run model' with 1000 permutations
% - 'Compute weights' -> create 'svm_weights' image
% - 'Feature set', DCT detrending and a 2nd level mask (fusiform gyrus)
% - 'Specify model', multi-GPC Faces vs Houses vs Shoes, LOBO CV
% - 'Run model' without any permutation
% - 'Compute weights' -> create 'mgpc_weights' image

% select images, SPM.mat and mask(s)
d_dir = fullfile(rdata_dir,'fMRI');
[img_files] = spm_select('FPList',d_dir,'^w.*\.nii$');
s_dir = fullfile(rdata_dir,'design');
[spm_file] = spm_select('FPList',s_dir,'^SPM\.mat$');
m_dir = fullfile(rdata_dir,'masks');
[msk_file] = spm_select('FPList',m_dir,'^.*\.img$');

% load batch file
b_file = fullfile(prt('dir'),'_unitTests','batch_test_HaxbyData.mat');
load(b_file)

% set files: (1) images, (2) SPM.mat, (3) mask 1st level, (4) mask 2nd level
matlabbatch{1}.cfg_basicio.cfg_named_file.files{1} = cellstr(img_files);
matlabbatch{1}.cfg_basicio.cfg_named_file.files{2} = cellstr(spm_file);      
matlabbatch{1}.cfg_basicio.cfg_named_file.files{3} = cellstr(msk_file(2,:)); 
matlabbatch{1}.cfg_basicio.cfg_named_file.files{4} = cellstr(msk_file(1,:)); 
% set directory where result directory is created = "root data directory"
matlabbatch{2}.cfg_basicio.cfg_named_dir.dirs{1} = {rdata_dir};

% run the job and catch the error if any.
ok = 1;
try
    cfg_util('run',matlabbatch)
catch ME
    disp(ME.message)
    ok = 0;
    return;
end

end

%==========================================================================
%% IXI data set
function ok = check_IXI(rdata_dir)
%
% This batch will go through the following modules, as saved in the
% batch_test_IXIdata.mat file:
% - 'File selector' for the 6 sets of images: 
%       Guys-divergence (g1m1), Guys-momentum (g1m2), 
%       HammersH-divergence (g2m1), HammersH-momentum (g2m2)
%       IOP-divergence (g3m1), IOP-momentum (g3m2)
% - 'File selector' for 2 masks: momentum, divergence (could be the same 
%   file actually and it will be defined so when filling the batch)
% - 'Directory selector' for the root of the data directory
% - 'Make directory', create 'test_results' directory at the root of the 
%   data directory
% - 'Data & design' with 3 groups (Guys/HammersH/IOP) and 2 modalities each
%   ('momentum'/'divergence'). No regression target defined here! They'll
%   be defined in the check function.
% - 'Feature set', only the 'divergence' data
% - 'Specify model', svm Guys-vs-(HammersH+IOP), on divergence data, 
%   leave-1s/gr-out CV
% - 'Run model' with 1000 permutations
% - 'Compute weights' -> create 'svm_GvsHI' image
% - 'Feature set', only the 'momentum' data
% - 'Specify model', KRR for age of all 3 groups of scans
% - 'Run model' with 1000 permutations
% - 'Feature set', pool 'momentum' and 'divergence' data together
% - 'Specify model', GPC Guys-vs-HammersH-vs-IOP, on 'momentum+divergence'
%   data leave-1s/gr-out
% - 'Run model' without permutation
% - 'Specify model', RVR for age of all 3 groups of scans (using momentum
%   feature set)
% - 'Run model' with 1000 permutations
% - 'Specify model', GPR for age of all 3 groups of scans (using momentum
%   feature set)
% - 'Run model' without permutation
%
% Note that the data only includes 5 subjects!

% set images directories and select mask(s)
d_dir{1} = fullfile(rdata_dir,'divergences');
d_dir{2} = fullfile(rdata_dir,'momentum');
m_dir = fullfile(prt('dir'),'masks');
[msk_file] = spm_select('FPList',m_dir,'^.*\.img$');

% load batch file
b_file = fullfile(prt('dir'),'_unitTests','batch_test_IXIdata.mat');
load(b_file)

% set files: images into 4 sets (g1m1-g1m2-g2m1-g2m2-g3m1-g3m2)
matlabbatch{1}.cfg_basicio.cfg_named_file.files{1} = cellstr(...
    spm_select('FPList',fullfile(d_dir{1},'Guys'),'^sdv.*\.nii$'));
matlabbatch{1}.cfg_basicio.cfg_named_file.files{2} = cellstr(...
    spm_select('FPList',fullfile(d_dir{2},'Guys'),'^sa.*\.nii$'));      
matlabbatch{1}.cfg_basicio.cfg_named_file.files{3} = cellstr(...
    spm_select('FPList',fullfile(d_dir{1},'HammerH'),'^sdv.*\.nii$')); 
matlabbatch{1}.cfg_basicio.cfg_named_file.files{4} = cellstr(...
    spm_select('FPList',fullfile(d_dir{2},'HammerH'),'^sa.*\.nii$')); 
matlabbatch{1}.cfg_basicio.cfg_named_file.files{5} = cellstr(...
    spm_select('FPList',fullfile(d_dir{1},'IOP'),'^sdv.*\.nii$')); 
matlabbatch{1}.cfg_basicio.cfg_named_file.files{6} = cellstr(...
    spm_select('FPList',fullfile(d_dir{2},'IOP'),'^sa.*\.nii$')); 

% set files: mask (1st level) for both modalities
matlabbatch{2}.cfg_basicio.cfg_named_file.files{1} = cellstr(msk_file);
matlabbatch{2}.cfg_basicio.cfg_named_file.files{2} = cellstr(msk_file);      

% set directory where result directory is created = "root data directory"
matlabbatch{3}.cfg_basicio.cfg_named_dir.dirs{1} = {rdata_dir};

% set regression target for momentum data (modality#2)
load(fullfile(rdata_dir,'reg_targets','rt_Guys.mat'))
matlabbatch{5}.prt.data.group(1).select.modality(2).rt_subj = rt;
load(fullfile(rdata_dir,'reg_targets','rt_HammerH.mat'))
matlabbatch{5}.prt.data.group(2).select.modality(2).rt_subj = rt;
load(fullfile(rdata_dir,'reg_targets','rt_IOP.mat'))
matlabbatch{5}.prt.data.group(3).select.modality(2).rt_subj = rt;

% run the job and catch the error if any.
ok = 1;
try
    cfg_util('run',matlabbatch)
catch ME
    disp(ME.message)
    ok = 0;
    return;
end

end

%==========================================================================
%% Faces Famous-vs-NonFamous data set
function ok = check_FvsNF(rdata_dir)

% This batch will go through the following modules, as saved in the
% batch_test_FacesData.mat file:
% - 'File selector' for 
%       (1/2) the 2 sets of images: 'Famous' and 'NonFamous' beta's
%       (3) the whole brain mask
% - 'Directory selector' for the root of the data directory
% - 'Make directory', create 'test_results' directory at the root of the 
%   data directory
% - 'Data & design', defining the 2 groups Famous/NonFamous and data
% - 'Feature set', using the beta images
% - 'Specify model', svm F-vs-NF, leave-1s-out CV
% - 'Run model' with 1000 permutations
% - 'Compute weights' -> create 'svm_FvsNF' image
% - 'Specify model', gpc F-vs-NF, leave-1s/gr-out CV
% - 'Run model' without permutations
% - 'Compute weights' -> create 'gpc_FvsNF' image

% select images, SPM.mat and mask(s)
d_dir = fullfile(rdata_dir,'Famous');
[imgF_files] = spm_select('FPList',d_dir,'^beta.*\.img$');
d_dir = fullfile(rdata_dir,'NonFamous');
[imgNF_files] = spm_select('FPList',d_dir,'^beta.*\.img$');
m_dir = fullfile(prt('dir'),'masks');
[msk_file] = spm_select('FPList',m_dir,'^.*\.img$');

% load batch file
b_file = fullfile(prt('dir'),'_unitTests','batch_test_FacesData.mat');
load(b_file)

% set files: (1) images, (2) SPM.mat, (3) mask 1st level, (4) mask 2nd level
matlabbatch{1}.cfg_basicio.cfg_named_file.files{1} = cellstr(imgF_files);
matlabbatch{1}.cfg_basicio.cfg_named_file.files{2} = cellstr(imgNF_files);      
matlabbatch{1}.cfg_basicio.cfg_named_file.files{3} = cellstr(msk_file); 
% set directory where result directory is created = "root data directory"
matlabbatch{2}.cfg_basicio.cfg_named_dir.dirs{1} = {rdata_dir};

ok = 1;
try
    cfg_util('run',matlabbatch)
catch ME
    disp(ME.message)
    ok = 0;
    return;
end

end

