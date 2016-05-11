function [dataStruct, classes] = prepTwoClassDataStruct(dataStruct, in)

index1                      = [];
for i = 1:length(in.groupings{1})
    index1                  = union(index1, find(dataStruct.class == in.groupings{1}(i)));
end
index2                      = [];
for i = 1:length(in.groupings{2})
    index2                  = union(index2, find(dataStruct.class == in.groupings{2}(i)));
end

classes                     = [    ones(length(index1), 1); ...
                               2 * ones(length(index2), 1)];

indexReordered              = [index1; index2];
dataStruct.class            = dataStruct.class(indexReordered);
dataStruct.data          	= dataStruct.data(indexReordered, :);
if isfield(dataStruct, 'id')
    dataStruct.id           = dataStruct.id(indexReordered, :);
end
if isfield(dataStruct, 'filenames')
    dataStruct.filenames  	= dataStruct.filenames(indexReordered);
end
if isfield(dataStruct, 'K')
    dataStruct.K            = dataStruct.K(indexReordered, indexReordered);
end