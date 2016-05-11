%*** toss out bad columns
if cleanColumns
    indexBadCols_features 	= find(max(~isfinite(featureStruct.data),       	[], 1));
    indexBadCols_pairs     	= find(max(~isfinite(featureStruct.pwPCA.data.rc1),	[], 1));

    indexGood            	= setdiff(1:size(featureStruct.data, 2), union(indexBadCols_features, indexBadCols_pairs));
    featureStruct.data   	= featureStruct.data(:,            indexGood);
    if mlAlgo.useMatchedPCA
        featureStruct.pwPCA.data.rc1 = featureStruct.pwPCA.data.rc1(:, 	indexGood);
    end    
end
