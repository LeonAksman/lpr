function mask               = loadMask(maskFilename, maskValidIndeces)

addpath '../NIFTI_toolbox';

if nargin < 2
    maskValidIndeces        = [];
end

nii_mask                    = load_untouch_nii(maskFilename); 
mask.dim                  	= size(nii_mask.img);
mask.validIndeces         	= find(nii_mask.img(:) > 0);    

if ~isempty(maskValidIndeces)
    mask.validIndeces     	= intersect(mask.validIndeces , maskValidIndeces);
end
