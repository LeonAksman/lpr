function [interSet, index_set1, index_set2] = intersectAll(set1, set2)

interSet                                    = intersect(set1, set2);

index_set1                                  = find(ismember(set1, interSet));
index_set2                                  = find(ismember(set2, interSet));