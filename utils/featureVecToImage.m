function imageMat               = featureVecToImage(featureVec, mask)

imageMat                        = zeros(prod(mask.dim), 1);
imageMat(mask.validIndeces)  	= featureVec;

imageMat                        = reshape(imageMat, mask.dim);