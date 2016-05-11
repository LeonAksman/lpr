%INPUT:
% classSets:         cell array of class sets: e.g. {[1 2], [3]} -> classify 1 + 2 vs 3
% dataStruct fields: class -> n x 1 vector of numeric classes, data -> n x p matrix
% algo
%
function out                        = classify(in, dataStruct)

out                                 = in;

[classes, indexClasses]           	= getClasses(dataStruct.class, in.groupings);

assert(~isfield(dataStruct, 'K')); %can't handle this

out.dataStruct                      = reindexStruct(dataStruct, indexClasses);
out.dataStruct.classes              = classes;


[out.structs_cv, out.struct_full]   = feval(in.algo.cv.fnHandle, classes, out.dataStruct, in.algo);





%************************************************
function [classes, indexClasses]   	= getClasses(class, groupings)

classes                             = [];
indexClasses                        = [];

for i = 1:length(groupings)
    index_i                         = [];
    for j = 1:length(groupings{i})
        %index_i                     = union(index_i, find(class == groupings{i}(j)));
        index_i                     =[index_i; find(class == groupings{i}(j))];
    end
    
    indexClasses                    = [indexClasses;    index_i];
    
    classes                         = [classes;         i * ones(length(index_i), 1)];
    
end

%dispf('%d/%d', sum(classes==1), sum(classes==2));                           
