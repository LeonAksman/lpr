function w      = weights_svm(in)

w               = in.dataStruct.data' * in.struct_full.alpha;