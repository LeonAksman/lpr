function featureStruct              = loadFeatureStruct_longitudinal(in)

%in: followupMapping, maskFilename, pairsMapping

%**** load timepoint
featuresFileStruct.mask             = in.maskFilename;
featuresFileStruct.maskValidIndeces = in.maskValidIndeces;
featuresFileStruct.mapping          = in.crossSectionalMapping;    
featuresFileStruct.mappingStyle     = 'fullpath';               %'names' or 'fullpath'
featuresFileStruct.mappingFields    = 'file\tmr_id\ttime\tid\tclass';
featureStruct                       = loadFeatureStruct(featuresFileStruct); 

%**** load pairs
featuresFileStruct.mask             = in.maskFilename;
featuresFileStruct.maskValidIndeces = in.maskValidIndeces;
featuresFileStruct.mapping          = in.longitudinalMapping;
featuresFileStruct.mappingStyle     = 'fullpath';   %'names' or 'fullpath'
featuresFileStruct.mappingFields    = 'file\tmr_id\ttime\tid\tclass';
featureStruct_longitudinal         	= loadFeatureStruct(featuresFileStruct);    

subj_ids                           	= featureStruct_longitudinal.id;
unique_ids                          = unique(subj_ids);

featureStruct.ltcPCA.raw.data      	= zeros(size(featureStruct_longitudinal.data)); 
featureStruct.ltcPCA.raw.time     	= zeros(size(featureStruct_longitudinal.data, 1), 1);
featureStruct.ltcPCA.raw.id        	= cell(size(featureStruct_longitudinal.data, 1), 1);
featureStruct.ltcPCA.raw.filename  	= cell(size(featureStruct_longitudinal.data, 1), 1);

for i = 1:length(unique_ids)
    index_i                         = sort(find(strcmp(subj_ids, unique_ids{i})), 'ascend');
   
    %reindex based on sorted delays
    [~, index_sorted]             	= sort(featureStruct_longitudinal.time(index_i), 'ascend');
    index_i                         = index_i(index_sorted);

    data_i                          = featureStruct_longitudinal.data(index_i,:);
    times_i                         = featureStruct_longitudinal.time(index_i);
    
    featureStruct.ltcPCA.raw.data(index_i, :)  = data_i;
    featureStruct.ltcPCA.raw.time(index_i)     = times_i;
    featureStruct.ltcPCA.raw.id(index_i)       = repmat(unique_ids(i), length(times_i), 1);
    featureStruct.ltcPCA.raw.filename(index_i) = featureStruct_longitudinal.filenames(index_i);
    
    if length(index_i) == 1
        continue;
    end
            
    mr_ids_i                        = featureStruct_longitudinal.mr_id(index_i);    
    dispf('Adding mr ids: %s', strjoin(mr_ids_i', '\t'));
end

featureStruct.class             = formNumericClasses(featureStruct.class, in.diseaseStates);

%***** get the class indeces
assert(length(in.groupings) == 2);
indexClass1                     = [];
for i = 1:length(in.groupings{1})
    indexClass1                 = [indexClass1; find(featureStruct.class == in.groupings{1}(i))];
end
indexClass2                     = [];
for i = 1:length(in.groupings{2})
    indexClass2                 = [indexClass2; find(featureStruct.class == in.groupings{2}(i))];
end
indexClasses                    = [indexClass1;                     indexClass2];
classes                         = [ones(length(indexClass1), 1);    2 * ones(length(indexClass2), 1)];

if in.intersectWithLongitudinal
    
    featureStruct               = reindexStruct(featureStruct, indexClasses);
    
    [~, ia, ib]                 = intersectAll(featureStruct.id, featureStruct.ltcPCA.raw.id); %intersect

    featureStruct             	= reindexStruct(featureStruct,              ia);
    featureStruct.ltcPCA.raw  	= reindexStruct(featureStruct.ltcPCA.raw,   ib);

    featureStruct.class2       	= classes(ia);
end
