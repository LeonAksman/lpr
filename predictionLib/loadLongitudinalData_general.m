function featureStruct              = loadLongitudinalData_general(in)

featureStruct                       = loadFeatureStruct_longitudinal(in);

%********** filter for ids that have at least X time-points
unique_ids                          = unique(featureStruct.ltcPCA.raw.id);
indexGood                           = [];

for i = 1:length(unique_ids)
    index_i                         = find(strcmp(featureStruct.ltcPCA.raw.id, unique_ids{i}));
           
    if length(index_i) >= in.algo.input.minClassificationSetSamples  
        
        switch in.algo.input.samplesChosen
            case 'all'
                indexGood         	= [indexGood; index_i];              % all three+
            case 'lastTwo'
                indexGood          	= [indexGood; index_i((end-1):end)]; % last two
            case 'firstLast'
                indexGood       	= [indexGood; index_i([1 end])];     % first, last
            otherwise
                error('unknown samplesChosen style %s', in.algo.input.samplesChosen);
        end        
    end
end

featureStruct.ltcPCA.raw          	= reindexStruct(featureStruct.ltcPCA.raw, indexGood);

uniqueIdGood                    	= unique(featureStruct.ltcPCA.raw.id);
indexGood_featureStruct             = ismember(featureStruct.id, uniqueIdGood);
featureStruct                       = reindexStruct(featureStruct, indexGood_featureStruct);

featureStruct.ltcPCA.coeffs_P1      	= calcCoeffsMatrices(featureStruct.ltcPCA.raw.id,     	...
                                                             featureStruct.ltcPCA.raw.data,    	...
                                                             featureStruct.ltcPCA.raw.time,     ... 
                                                             1);
if in.algo.input.P == 2;
    featureStruct.ltcPCA.coeffs_P2  	= calcCoeffsMatrices(featureStruct.ltcPCA.raw.id,      	...
                                                             featureStruct.ltcPCA.raw.data,   	...
                                                             featureStruct.ltcPCA.raw.time,   	... 
                                                             2);
end