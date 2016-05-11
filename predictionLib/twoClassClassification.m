%INPUT:
% classSets:         cell array of class sets: e.g. {[1 2], [3]} -> classify 1 + 2 vs 3
% dataStruct fields: class -> n x 1 vector of numeric classes, data -> n x p matrix
% algo
%
function out                = twoClassClassification(in, dataStruct, algo)

out                         = in;

%load the mat file
if isfield(algo, 'saveMat') && ~isempty(algo.saveMat) && fileExist(algo.saveMat)
    loaded                  = load(algo.saveMat);
    
    out.structs_cv          = loaded.out.structs_cv;   
    out.struct_full         = loaded.out.struct_full;  
    
    return
end

%****************************************

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

dispf('%d/%d', sum(classes==1), sum(classes==2));                           
                           
indexReordered              = [index1; index2];
dataStruct.class            = dataStruct.class(indexReordered);
dataStruct.data          	= dataStruct.data(indexReordered, :);
if isfield(dataStruct, 'class2')
    dataStruct.class2     	= dataStruct.class2(indexReordered);
end
if isfield(dataStruct, 'id')
    dataStruct.id           = dataStruct.id(indexReordered, :);
end
if isfield(dataStruct, 'filenames')
    dataStruct.filenames  	= dataStruct.filenames(indexReordered);
end
if isfield(dataStruct, 'K')
    dataStruct.K            = dataStruct.K(indexReordered, indexReordered);
end

out.dataStruct              = dataStruct;

[out.structs_cv, out.struct_full]   = feval(algo.cv.fnHandle, classes, dataStruct, algo);
% 
% %load the mat file
% matLoaded                   = false;
% if isfield(algo, 'saveOutMat') && ~isempty(algo.saveOutMat) && fileExist(algo.saveOutMat)
%     loaded                  = load(algo.saveOutMat);
%     
%     out.structs_cv          = loaded.out.structs_cv;    %loaded.outStructs_cv; 
%     out.struct_full         = loaded.out.struct_full;   %loaded.outStruct_full;
%     
%     matLoaded               = true; %loaded.isDone;
% end
% 
% %*** run the cvPrediction function of choice
% if ~matLoaded        
%     [out.structs_cv, out.struct_full]   = feval(algo.cv.fnHandle, classes, dataStruct, algo);
% end
% 
% %save the mat file
% if ~matLoaded && isfield(algo, 'saveOutMat') && ~isempty(algo.saveOutMat) && ~fileExist(algo.saveOutMat)
%     disp('Saving output structure...');
%     save(algo.saveOutMat, 'in', 'dataStruct', 'out');
%     disp('done.');
% end