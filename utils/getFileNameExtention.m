function nameExts       = getFileNameExtention(filenames)


n                       = length(filenames);

nameExts                = cell(n, 1);
for i = 1:n
    
    [~, name, ext]      = fileparts(filenames{i});

    nameExts{i}         = [name ext];
end
