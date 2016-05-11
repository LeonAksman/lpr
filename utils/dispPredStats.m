function outString  = dispPredStats(performanceMetrics, dispLabel)

% part1               = sprintf('%30s, Balanced Accuracy, %.1f, Unweighted Accuracy, %.1f',	dispLabel,                                    	...
%                                                                                             performanceMetrics.bacc         * 100,        	...
%                                                                                             performanceMetrics.acc          * 100);
part1               = sprintf('%30s, Balanced Accuracy, %.1f',                              dispLabel, performanceMetrics.bacc * 100);

if all(isfield(performanceMetrics, {'sensitivity', 'specificity', 'ppv', 'npv', 'auc'})) 
    
    part2           = sprintf(' Sensitivity, %.1f, Specificity, %.1f, PPV, %.1f, NPV, %.1f, ROC AUC: %.03f',performanceMetrics.sensitivity  * 100,        	...
                                                                                            performanceMetrics.specificity  * 100,         	...
                                                                                            performanceMetrics.ppv          * 100,       	...
                                                                                            performanceMetrics.npv          * 100,          ...
                                                                                            performanceMetrics.auc);     
        
    outString       = [part1 part2]; 
else
    outString       = part1;
end
        
disp(outString);
