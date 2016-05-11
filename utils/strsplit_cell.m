function cellOut = strsplit_cell(cellIn, delim)

nRows       = length(cellIn);
nCols       = length(strsplit(cellIn{1}, delim));

cellOut     = cell(nRows, nCols);
for i = 1:nRows
    cellOut(i, :) = strsplit(cellIn{i}, delim);
end