function outFilenames   = splitCellArrayToFiles(inCellArray, fullFilePrefix, numSubFiles)

outFilenames            = cell(numSubFiles, 1);

n                       = length(inCellArray);
for i = 1:numSubFiles
    file_i              = [fullFilePrefix num2str(i) '.txt'];
    
    if i < numSubFiles
        index_i         = ((i-1) * floor(n/numSubFiles) + 1):(i * floor(n/numSubFiles));
    else
        index_i         = ((i-1) * floor(n/numSubFiles) + 1):n;
    end        
    
    
    cells_i             = inCellArray(index_i);
    writeCellArray(file_i, cells_i, true);
    
    outFilenames{i}     = file_i;
end

