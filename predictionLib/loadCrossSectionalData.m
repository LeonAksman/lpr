function featureStruct              = loadCrossSectionalData(in)

% %in: followupMapping, maskFilename, pairsMapping
% 
% %**** load timepoint
% featuresFileStruct.mask             = in.mask;
% featuresFileStruct.maskValidIndeces = in.maskValidIndeces;
% featuresFileStruct.mapping          = in.mapping;    
% featuresFileStruct.mappingStyle     = in.mappingStyle;              %'names' or 'fullpath'
% featuresFileStruct.mappingFields    = in.mappingFields;

featureStruct                       = loadFeatureStruct(in.featuresFileStruct); 
featureStruct.class                 = formNumericClasses(featureStruct.class, in.diseaseStates);
