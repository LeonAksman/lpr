function evalMedianMetrics(evalString)

%[metrics_notMatched, metrics_matched] = analyzeOasis_harvardOxford_varyDelay_param_10fold(2, 700);
[metrics_notMatched, metrics_matched] = eval(evalString);

dispMedianMetrics(metrics_notMatched, metrics_matched);