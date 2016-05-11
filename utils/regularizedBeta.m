function y = regularizedBeta(x, a, b)

y = betainc(x, a, b) / beta(a, b);