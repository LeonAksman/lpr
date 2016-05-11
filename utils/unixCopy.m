function unixCopy(filepathsFromToFilename)

[filepathsFrom, filepathsTo]  = textread2(filepathsFromToFilename, '%s\t%s');

for i = 1:length(filepathsFrom)
    str_i               = ['cp ' filepathsFrom{i} ' ' filepathsTo{i}];
    disp(str_i);
    unix(str_i);
end
