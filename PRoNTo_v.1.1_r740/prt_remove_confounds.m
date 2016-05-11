function [Kr, R] = prt_remove_confounds(K,C)

% [Kr, R] = prt_remove_confounds(K,C)
%
% Function to remove confounds from kernel.
%__________________________________________________________________________
% Copyright (C) 2011 Machine Learning & Neuroimaging Laboratory

% Written by A. Marquand
% $Id: prt_remove_confounds.m 741 2013-07-22 14:07:36Z mjrosa $


n  = size(K,1);
R  = eye(n)-C*pinv(C); %R=eye(n)-C*inv(C'*C)*C'
Kr = R'*K*R;

return