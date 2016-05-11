function xSmooth = gaussSmooth(x, windowLength)

gaussFilter     = gausswin(windowLength);

% Normalize.
gaussFilter     = gaussFilter / sum(gaussFilter); 

% Do the blur.
xSmooth         = conv(x, gaussFilter);