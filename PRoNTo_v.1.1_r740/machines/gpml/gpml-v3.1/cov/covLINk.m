function K = covLINk(hyp, x, z, i)

% Linear covariance function with a single hyperparameter. The covariance
% function is parameterized as:
%
% k(x,z) = (x'*z)/t2;
%
% The hyperparameter controls the scaling of the latent function:
%
% hyp = [ log(sqrt(t2)) ]
%__________________________________________________________________________
% This script is based on a script derived from the GPML toolbox, which is
% Copyright (C) Carl Rasmussen and Hannes Nickisch, 2011.

% Written by L Aksman Dec. 1, 2014

if nargin<2, K = '1'; return; end                  % report number of parameters
if nargin<3, z = []; end                                   % make sure, z exists
xeqz = numel(z)==0; dg = strcmp(z,'diag') && numel(z)>0;        % determine mode

it2 = exp(-2*hyp);                                             % t2 inverse


% compute inner products
if dg                                                               % vector kxx
  %*** removed
  K = sum(x.*x,2);
  
  %*** added
  %K = prt_centre_kernel(x.*x);
  %K = sum(diag(K), 2);
  
else
  if xeqz                                                 % symmetric matrix Kxx
 	%*** removed
    K = x*x';
    
    %*** added
    %K = prt_centre_kernel(x*x');
    
  else                                                   % cross covariances Kxz
    %*** removed
  	K = x*z';
    
    %*** added
    %[~, K] = prt_centre_kernel(x*x', x*z');
    
  end
end


if nargin<4 % return covariances
  K = it2*K;
else % return derivatives
  if i==1
    K = -2*it2*K;
  else
    error('Unknown hyperparameter')
  end
end
