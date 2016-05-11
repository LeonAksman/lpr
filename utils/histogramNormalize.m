function x_normed = histogramNormalize(x)

[~, index]      = sort(x, 'ascend');
referenceHist   = randn(length(x), 1);
x(index)        = sort(referenceHist, 'ascend');

x_normed        = x;