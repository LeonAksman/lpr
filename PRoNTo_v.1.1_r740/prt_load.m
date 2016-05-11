function PRT = prt_load(fname)

% Function to load the PRT.mat and check its integrity regarding the 
% kernels and feature sets that it is supposed to contain. Updates the  set
% feature name if needed.
%
% input  : name of the PRT.mat, path included
%
% output : PRT structure updated
%_______________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by J. Schrouff
% $Id: prt_load.m 741 2013-07-22 14:07:36Z mjrosa $

try
    load(fname)
catch
    beep
    disp('Could not load file')
    PRT = [];
    return
end

% get path
prtdir = fileparts(fname);

% for each feature set, check that the corresponding .dat is present in the
% same directory and update the name of the file array if needed
if isfield(PRT,'fas') && ~isempty(PRT.fas)
    ind = [];
    for i=1:length(PRT.fas)
        % get the name of the file array
        if ~isempty(PRT.fas(i).dat)
            fa_name=PRT.fas(i).dat.fname;
            if ~ispc
                fname = strrep(fname,'\',filesep); 
            end 
            [fadir,fan,faext] = fileparts(fa_name);    
            if ~strcmpi(fadir,prtdir) % directories of PRT and feature set are different
                if ~exist(fullfile(prtdir,[fan,faext]),'file')  % no feature set found
                    beep
                    disp(['No feature set named ',fan,' found in the PRT directory'])
                    disp('Information linked to that feature set is deleted')
                    disp('Computing the weights or using non-kernel methods using that feature set won''t be permitted')
                else  % file exists but under the new directory
                    PRT.fas(i).dat.fname = fullfile(prtdir,[fan,faext]);
                    ind = [ind,i];
                end
            else
                ind = [ind,i];
            end
        end
    end
    if isempty(ind)
        PRT = rmfield(PRT,'fas');
        PRT = rmfield(PRT,'fs');
    elseif length(ind)~=i
        % When a model comports the modality of the deleted fas, get rid of
        % the corresponding fs and model
        PRT.fas = PRT.fas(ind);
    end
end

save([prtdir,filesep,'PRT.mat'],'PRT')
