function classesNumeric             = formNumericClasses(classesStates, states)

%************* form numeric classes
classesNumeric                   	= zeros(length(classesStates), 1);
for i = 1:length(states)
    index_i                         = find(strcmp(classesStates, states{i}));
    classesNumeric(index_i)       	= i * ones(length(index_i), 1);
end

if ~isempty(find(classesNumeric == 0))
    error('Not all classes searched for!');
end
