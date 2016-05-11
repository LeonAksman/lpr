%given probabilistic prediction in range 0-1 and class decision threshold in that range,
%return class label 1 or 2.
function classOneORTwo  = prob2TwoClass(p, threshold)

classOneORTwo          	= -1*double(p >= threshold) + 2;
