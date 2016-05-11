function viewFeatureHistograms(featureMat, indexColor1, indexColor2)

[n, ~] = size(featureMat);

assert(isempty(setdiff(1:n, [indexColor1; indexColor2])));

figure(1);
hold on;
for i = 1:n
    if any(i == indexColor1)
        histogram(featureMat(i, :), 'FaceColor', 'blue');
    else
        histogram(featureMat(i, :), 'FaceColor', 'red');
    end
end