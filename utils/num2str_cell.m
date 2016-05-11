function cells  = num2str_cell(nums)

%cells           = strread(num2str(nums), '%f');

cells            = cell(size(nums));
for i = 1:length(cells)
    cells{i}    = num2str(nums(i));
end


