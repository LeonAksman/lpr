function f = softThreshold(x, threshold)

f = sign(x) .* max(abs(x) - threshold, 0);