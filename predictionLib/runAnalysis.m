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