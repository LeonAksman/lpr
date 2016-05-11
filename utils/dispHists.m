function dispHists(figure_index, age, indexClass1, indexClass2)

centers                         = single(min(age):3:max(age));    
figure(figure_index(1));  
hist1                           = histogram(age(indexClass1), centers);
figure(figure_index(2));
hist2                           = histogram(age(indexClass2), centers);