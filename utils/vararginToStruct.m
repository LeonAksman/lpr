%convert string/value pairs to structure
function argStruct = vararginToStruct(varargin)

%make sure there is even # of elements
assert(mod(length(varargin{:}), 2) == 0);

n_pairs     = length(varargin{:})/2;

argStruct   = struct;
for i = 1:n_pairs
    argStruct.(varargin{1}{2*i-1}) = varargin{1}{2*i};
end
