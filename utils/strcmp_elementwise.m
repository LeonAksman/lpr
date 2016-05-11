function out            = strcmp_elementwise(cellstr1, cellstr2)

assert(length(cellstr1) == length(cellstr2), 'length(cellstr1) == length(cellstr2)');

n                       = length(cellstr1);

out                     = zeros(n, 1);
for i = 1:n
    out(i)              = strcmp(cellstr1{i}, cellstr2{i});
end