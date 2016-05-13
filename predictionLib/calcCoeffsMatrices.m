%    Where we build the coefficient matrices using subjects' scans for a desired model order P
%    Copyright (C) 2016  Leon Aksman
%
%    This program is free software: you can redistribute it and/or modify
%    it under the terms of the GNU General Public License as published by
%    the Free Software Foundation, either version 3 of the License, or
%    (at your option) any later version.
%
%    This program is distributed in the hope that it will be useful,
%    but WITHOUT ANY WARRANTY; without even the implied warranty of
%    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%    GNU General Public License for more details.
%
%    You should have received a copy of the GNU General Public License
%    along with this program.  If not, see <http://www.gnu.org/licenses/>
%
function coeffs                 = calcCoeffsMatrices(ids, featuresMat, t, P)

assert(length(ids) == size(featuresMat, 1) && ...
       length(ids) == length(t));
assert(P > 0 && P < 3);                         %P = 1 or 2 for now

%*******************************************************
%toss subjects with not enough samples
minSamples                      = P + 1;
goodIndex                     	= [];
unique_ids                      = unique(ids);
for i = 1:length(unique_ids)
    index_i                     = find(strcmp(ids, unique_ids{i}));
    if length(index_i) >= minSamples
        goodIndex               = [goodIndex; index_i];
    end
end    
ids                             = ids(goodIndex);
featuresMat                     = featuresMat(goodIndex, :);
t                               = t(goodIndex);
%*******************************************************

%********* form subject specific models and solve them
unique_ids                      = unique(ids);
n                               = length(unique_ids);
D                               = size(featuresMat, 2);

dispf('calc B mats, P = %d...', P);
B_all                           = zeros(n * (P + 1), D);
for i = 1:n
    index_i                     = find(strcmp(ids, unique_ids{i}));
    
    %number of samples for this subject and vector of times
    m_i                         = length(index_i);   
    t_i                         = t(index_i);   
    
    %make sure times are in ascending order
    assert(all(diff(t_i) > 0)); 
    
    %create longitudinal design matrix
    Z_i                         = zeros(m_i, P + 1);
    for j = 0:P
        Z_i(:, j+1)             = t_i .^ j;
    end
    
    %compute subject's coefficient matrix
    X_i                         = featuresMat(index_i, :);
    B_si                        = pinv(Z_i) * X_i;
    
    %store in matrix of all subjects' coefficients
    rowIndices                  = ((i-1) * (P + 1) + 1):(i * (P + 1));
    B_all(rowIndices, :)        = B_si;
end
disp('done.');


coeffs.ids                      = unique_ids;
coeffs.P                        = P;
for p = 0:P
    coeffs.(['B_p' num2str(p)]) = B_all((p+1):(P+1):end, :);
end
