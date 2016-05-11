function cellString = cellArrayToString(cellArray)

cellString          = '';
for i = 1:length(cellArray)
    cellString      = [cellString sprintf('%s\r\n', cellArray{i})];
end