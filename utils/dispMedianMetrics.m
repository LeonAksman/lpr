function dispMedianMetrics(metrics_notMatched, metrics_matched)

if length(metrics_notMatched) > 1
    indexMiddle         = floor(length([metrics_matched.bacc])/2);
else
    indexMiddle         = 1;
end

perfDiff            = [metrics_matched.bacc] - [metrics_notMatched.bacc];
[vals, indexSorted]    = sort(perfDiff, 'ascend');

indexMedian         = indexSorted(indexMiddle);

disp(['Sorted diffs: ' sprintf('%.2f ', vals)]);
dispf('Median val:   %.2f', vals(indexMiddle));
dispf('Median index: %d', indexMedian);

if isfield(metrics_notMatched, 'target')
    uniqueTargets  	= unique(metrics_notMatched.target);
    assert(all(uniqueTargets == [1 2]));
    dispf('class 1 (n == %d) vs class 2 (n == %d)', sum(metrics_notMatched.target==1), sum(metrics_notMatched.target==2));
end

dispPredStats(metrics_notMatched(indexMedian),  'Unmatched');
dispPredStats(metrics_matched(indexMedian),     'Matched  ');



