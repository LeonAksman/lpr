function w      = calcWeightVector_svm(in)

w               = in.dataStruct.data' * in.structs_full.alpha;