function cellOut = reindexCellArray(cellIn, index)

cellOut = cellIn;

for i = 1:length(cellOut)
    cellOut{i} = cellOut{i}(index);
end
