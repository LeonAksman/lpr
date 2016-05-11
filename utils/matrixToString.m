function matrixToString(M, format)

%this doesn't really work, just an example

fprintf(fid, [strjoin(names, '\t') '\n']);
for i = 1:size(M, 1)    
    fprintf(fid, '%d%s\n', M(i, 1), sprintf('\t%d', M(i, 2:end)));
end
fclose(fid);