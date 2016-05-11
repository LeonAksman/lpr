function filenames_out          = fileparts_custom(filenames, pathstr, prefix, suffix, ext)

if nargin < 2
    pathstr                     = '';
end
if nargin < 3
    prefix                      = '';
end
if nargin < 4
    suffix                      = '';
end
if nargin < 5
    ext                         = '';
end

filenames_out                   = cell(length(filenames), 1);

for i = 1:length(filenames)
    [~, name_i, ext_i]          = fileparts(filenames{i});
    
    if isempty(ext)
        ext                     = ext_i;
    end        
    if ~isempty(pathstr)
        filenames_out{i}      	= fullfile(pathstr,  [prefix name_i suffix ext]);
    else
        filenames_out{i}      	= [prefix name_i suffix ext];
    end
end
