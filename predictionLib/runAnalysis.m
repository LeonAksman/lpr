%    Run the analysis based on the function handles for loading/analyzing/evaluating that come from top level file
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
function metrics                    = runAnalysis(in)

if ~in.DEBUG && fileExist(in.metricsFilename) 


    dispf('Loading %s', in.metricsFilename);

    s                           	= load(in.metricsFilename);
    metrics                         = s.metrics;

    dispPredStats(metrics,     in.analysisName);

    return;
end

featureStruct                       = feval(in.fnLoad,      in);
analysisStruct                  	= feval(in.fnAnalyze,   in, featureStruct);
metrics                             = feval(in.fnEvaluate,  in, analysisStruct);

if ~in.DEBUG && ~isempty(in.metricsFilename)
    save(in.metricsFilename, 'metrics');
end
