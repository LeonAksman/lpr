function tokens                 = unixTokenize(unixCommand)

[status, output]                = unix(unixCommand);
tokens                          = strsplit(output);

%chop out empties
for i = 1:length(tokens)
    if isempty(tokens{i})
        tokens                  = [tokens(1:(i-1)) tokens((i+1):end)]; 
        continue;
    end
end