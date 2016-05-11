%input, structure with fields:
% maskFile        - filename of binary mask to be applied to each image.
%                   can be blank, in which case analysis will be on
%                   unmasked images
% mappingFile     - file with 2 columns: image filenames and corresponding class, tab delimited
%                 ex. zzz.img\tHealthy
%output:
% featureStruct - structure with 2 fields: 
%                   data     - n x d numeric feature matrix, 
%                   class    - n x 1 string class name, e.g. 'Healthy'


% featuresFileStruct.dataDir     	= dataDir;
% featuresFileStruct.mask           = 'mask_template6_GM_pt05.nii';
% featuresFileStruct.mapping        = featuresFilenames;
function featureStruct          = loadFeatureStruct(fileStruct)

addpath '../utils';
addpath '../NIFTI_toolbox';

if nargin < 2
    logTransform                = false;
end

%*********************************************

if isempty(fileStruct.mask)
    disp('WARNING: no mask file indicated. Analysis will proceed on unmasked images.');    
    mask_dim                    = [];
    mask_index                  = [];
else
    disp('Loading masking ...');    
    nii_mask                    = load_untouch_nii(fileStruct.mask);  %load_nii(imageFilenames{i});  %
    mask_dim                  	= size(nii_mask.img);
    mask_index                	= find(nii_mask.img(:) > 0);    
    
    if isfield(fileStruct, 'maskValidIndeces') && ~isempty(fileStruct.maskValidIndeces)
        mask_index              = intersect(mask_index, fileStruct.maskValidIndeces);
    end
    
    disp('done.');
end
%*********************************************

disp('Loading features...');


switch fileStruct.mappingFields
    case 'file\tclass'
        [imageFilenames, imageClasses]              = textread2(fileStruct.mapping, '%s\t%s');    
    case 'file\tid\tclass'
        [imageFilenames, imageIds, imageClasses]  	= textread2(fileStruct.mapping, '%s\t%s\t%s');
        featureStruct.id                            = imageIds;   
    case 'file\tid\tclass\ttime'
        [imageFilenames, imageIds, imageClasses, imageTimes]  	= textread2(fileStruct.mapping, '%s\t%s\t%s\t%f');
        featureStruct.id                            = imageIds;     
        featureStruct.time                          = imageTimes;
    case 'file\tmr_id\tid\tclass'
        [imageFilenames, imageMrIds, imageIds, imageClasses]  	= textread2(fileStruct.mapping, '%s\t%s\t%s\t%s');
        featureStruct.mr_id                         = imageMrIds;
        featureStruct.id                            = imageIds;           
    case 'file\tmr_id\ttime\tid\tclass'
        [imageFilenames, imageMrIds, imageTimes, imageIds, imageClasses]  	= textread2(fileStruct.mapping, '%s\t%s\t%f\t%s\t%s');
        featureStruct.mr_id                         = imageMrIds;
        featureStruct.id                            = imageIds;     
        featureStruct.time                          = imageTimes;        
    otherwise
        [imageFilenames, imageClasses]              = textread2(fileStruct.mapping, '%s\t%s');
end

dim1                            = [];

featureStruct.class             = imageClasses;
if strcmp(fileStruct.mappingStyle, 'fullpath')
    featureStruct.filenames     = imageFilenames;
else
    featureStruct.filenames     = fullfile(fileStruct.dataDir, imageFilenames);
end
featureStruct.mask.validIndeces = mask_index;
featureStruct.mask.dim          = mask_dim;
featureStruct.data            	= [];

n                               = length(featureStruct.class);


%preallocate based on mask dims - equality with mask dims is therefore mandatory
if ~isempty(mask_index)
    %featureStruct.data      	= zeros(n, prod(mask_dim));
    featureStruct.data        	= zeros(n, length(mask_index));
end

for i = 1:n
    
    disp(sprintf('%d/%d', i, n));

    nii_i                        = load_untouch_nii(featureStruct.filenames{i});  %load_nii(featureStruct.filenames{i});  %
      
    %check vs all others
    if isempty(dim1)
        dim1                    = size(nii_i.img);   
        
        %pre-allocate data matrix in case there is no mask
        if isempty(mask_dim)
            featureStruct.data  = zeros(n, prod(dim1));
        end
    elseif ~all(dim1 == size(nii_i.img))
        error('Inconsistent dimensions across input image filenames.');
        
    end
    %check vs mask
    if ~isempty(mask_dim) && ~all(dim1 == mask_dim) 
    	error('Inconsistent dimensions vs mask.');
    end
   
    nii_i_vec                   = nii_i.img(:)';
    if ~isempty(mask_dim)
        nii_i_vec           	= nii_i_vec(mask_index);
    end
    
    %featureStruct.data       	= [featureStruct.data; nii_i_vec];
    featureStruct.data(i, :)    = nii_i_vec;
end


%**** remove NaNs 
%via deletion/zeroing of whole columns
%featureStruct.data          = cleanMat(featureStruct.data, 1, 0); %[]);   

%via zeroing of offending cells - pronto style
featureStruct.data(isnan(featureStruct.data)) = 0;


disp('done.');

