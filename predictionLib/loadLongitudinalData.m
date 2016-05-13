%    Load longitudinal data and create coefficient matrices for later analysis
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
function featureStruct              = loadLongitudinalData(in)

featureStruct                       = loadLongitudinallyMatchedData_allPoints(in);

%********** filter for ids that have at least X time-points
unique_ids                          = unique(featureStruct.pwPCA.raw.id);
indexGood                           = [];

for i = 1:length(unique_ids)
    index_i                         = find(strcmp(featureStruct.pwPCA.raw.id, unique_ids{i}));
           
    if length(index_i) >= in.algo.input.minClassificationSetSamples  
        
        switch in.algo.input.samplesChosen
            case 'all'
                indexGood         	= [indexGood; index_i];              % all three+
            case 'lastTwo'
                indexGood          	= [indexGood; index_i((end-1):end)]; % last two
            case 'firstLast'
                indexGood       	= [indexGood; index_i([1 end])];  % first, last
            otherwise
                error('unknown samplesChosen style %s', in.algo.input.samplesChosen);
        end
        
        %indexGood                   = [indexGood; index_i];              % all three+
        %indexGood                   = [indexGood; index_i((end-1):end)]; % last two
        %indexGood                   = [indexGood; index_i([1 end])];  % first, last

    end
end

featureStruct.pwPCA.raw             = reindexStruct(featureStruct.pwPCA.raw, indexGood);

uniqueIdGood                    	= unique(featureStruct.pwPCA.raw.id);
indexGood_featureStruct             = ismember(featureStruct.id, uniqueIdGood);
featureStruct                       = reindexStruct(featureStruct, indexGood_featureStruct);

t                                   = single(featureStruct.pwPCA.raw.delay)/365;

featureStruct.pwPCA.coeffs_P1      	= calcCoeffsMatrices(featureStruct.pwPCA.raw.id,         ...
                                                         featureStruct.pwPCA.raw.data,       ...
                                                         t,  ... 
                                                         1);
if in.algo.input.P == 2;
    featureStruct.pwPCA.coeffs_P2  	= calcCoeffsMatrices(featureStruct.pwPCA.raw.id,         ...
                                                         featureStruct.pwPCA.raw.data,       ...
                                                         t,                                 ... 
                                                         2);
end
