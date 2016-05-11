function w = prt_KRR(K,t,reg)

% w = prt_KRR(K,t,reg)
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by Carlton Chu
% $Id: prt_KRR.m 741 2013-07-22 14:07:36Z mjrosa $

w = (K+reg*eye(size(K)))\t;
return