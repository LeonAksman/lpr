inference_method    = @infExact;
mean_function       = {@meanConst};
covariance_function = {@covSEiso};

% initial hyperparameters
offset       = 1;
length_scale = 1;
output_scale = 1;
noise_std    = 0.05;

hyperparameters.mean = offset;
hyperparameters.cov  = log([length_scale; output_scale]);
hyperparameters.lik  = log(noise_std);

% add normal priors to each hyperparameter
priors.mean = {get_prior(@gaussian_prior, 0, 1)};
priors.cov  = {get_prior(@gaussian_prior, 0, 1), ...
               get_prior(@gaussian_prior, 0, 1};
priors.lik  = {get_prior(@gaussian_prior, log(0.01), 1};

% add prior to inference method
prior = get_prior(@independent_prior, priors);
inference_method = add_prior_to_inference_method(inference_method, prior);

% find MAP hyperparameters
map_hyperparameters = minimize(hyperparameters, @gp, 50, inference_method, ...
        mean_function, covariance_function, [], x, y);