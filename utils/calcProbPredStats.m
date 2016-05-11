function calcProbPredStats(t, p, label)

auc         = calcRocAuc(t, p);

n1          = sum(t == 1); 
n2          = sum(t == 2);
n           = n1 + n2;

i1          = t ==1;
i2          = t ==2;
H           = -n1/n*log2((n1-1)/(n-2)) -n2/n*log2((n2-1)/(n-2));
I           = 1/n*(sum(log2(p(i1,:))) + sum(log2(1-p(i2,:)))) + H;

tt          = double(t == 1);
Brier       = sum(sum(([tt 1-tt] - [p 1-p]).^2))/n;

disp(sprintf('%15s, ROC AUC, %.2f, Target info, I = %.2f, Brier, %.2f',     ...
                                                                    label,                  ...                                                            
                                                                    auc,                    ...
                                                                    I,                      ...
                                                                    Brier));