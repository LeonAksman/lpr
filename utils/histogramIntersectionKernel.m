function dist = histogramIntersectionKernel(hist1, hist2)

n = length(hist1);
m = length(hist2);
assert(n == m, 'histogramIntersectionKernel: n ~= m');

dist = 0;
for i = 1:n
    dist = dist + min(hist1(i), hist2(i));
end