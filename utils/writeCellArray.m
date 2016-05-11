function writeCellArray(filename, cellArray, bForce)

if nargin < 3
    bForce      = false;
end

if fileExist(filename) && ~bForce
    disp(['writeCellArray() will not overwrite ' filename '. Set force flag if necessary.']);
    return;
end

fid             = fopen(filename, 'w');

% for i = 1:length(cellArray)
%     fprintf(fid, sprintf('%s\r\n', cellArray{i}));
% end
fprintf(fid, cellArrayToString(cellArray));

fclose(fid);