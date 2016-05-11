function midp  = mcnemar_midp(pred1, pred2, target)

% "How to calculate the McNemar mid-p test"
% Supplementary materials to: 
%Fagerland, Lydersen, Laake
%"The McNemar test for binary matched-pairs data: mid-p and asymptotic are better than exact conditional"

% table           = zeros(2,2);
% 
% n_11            = sum(pred1 == target1);
% n_12            = sum(pred1 ~= target1);
% 
% n_22            = sum(pred2 == target2);
% n_21            = sum(pred2 ~= target2);
% 
% n               = n_12 + n_21;

% Count correct predictions
good1           = pred1==target;
good2           = pred2==target;


% Compute contingency table cells
n_12        	= sum(~good1 &  good2); % Missed by C1 and found by C2
n_21          	= sum( good1 & ~good2); % Found by C1 and missed by C2
n               = n_12 + n_21;

min_val         = min(n_12,n_21);
midp           	= 2 * binocdf(min_val, n, 0.5)   - binopdf(min_val, n, 0.5);
%midp           = 2 * binocdf(min_val-1, n, 0.5) + binopdf(min_val, n, 0.5);  %******* matlab's testcholdout version, same thing

%***** matlab's testcholdout
%[~, midp_matlab] = testcholdout(pred1, pred2, target);


%****** v2
test_stat       = (abs(n_12 - n_21) - 1).^2 / (n_12 + n_21);
p_chi           = chi2pdf(test_stat, 1);
