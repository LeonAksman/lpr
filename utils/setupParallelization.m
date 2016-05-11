function p              = setupParallelization(numWorkers)

delete(gcp('nocreate'));

p   = parpool(numWorkers);