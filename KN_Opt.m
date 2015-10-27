%% Use fixed coefficient model to find the starting point of random C model
clc; clear var; close all; rng('shuffle'); 
load data.mat;

nfixed = pred_num + serq_num + 2; % beta (vip*k); gamma (veggie)
fixed0 = 0.5 * ones(nfixed, 1);
f_fixed = @(x)KN_HomoLLH(x,...
                         ID_mat,...
                         prior_mat,...
                         pred_num,...
                         serq_num,...
                         n_continuous,...
                         vip_route);
% if check derivative, use "central finite difference", more accurate than
% the default forward finite deifference". 
ops_fixed = optimoptions(@fminunc, 'Algorithm', 'trust-region',...
        'DerivativeCheck', 'on', 'GradObj', 'on', 'Display', 'iter', ...
        'TolX', 1e-9, 'TolFun', 1e-9, 'MaxIter', 1000, ...
        'MaxFunEvals', 1e10, 'FinDiffType', 'central');
[par_fixed, fval_fixed, exitflag_fixed, output, grad] = ...
    fminunc(f_fixed, fixed0, ops_fixed);
fixed_beta  = par_fixed(1: pred_num + serq_num);
fixed_gamma = par_fixed(pred_num + serq_num + 1); 
fixed_delta = par_fixed(end);
figure(1); 
scatter(beta_mu, fixed_beta);
figure(2); 
scatter([gamma_mu, delta_mu], [fixed_gamma, fixed_delta]);

%% Create draws to be used in estimation
% let's follow STATA in using 50 Halton draws per consumer for primes 2 and 3, dropping the first 15 (burn) 
ndraws = 50;
haltondraws = haltonset(2 * choice_max + pred_num, 'Skip', 15);
haltondraws = scramble(haltondraws, 'RR2'); 
draws = zeros(vip, 2 * choice_max + pred_num, ndraws);
for i=1: 2 * choice_max+pred_num
     draws(:, i, :) = reshape(norminv(haltondraws(1: vip*ndraws, i), 0, 1), ...
         vip, ndraws);
end

%% Recover/Estimate random coefficient
nrandom = nfixed + 1 + pred_num + 1; % plus STD: 1 for gamma; k for beta
random0 = [par_fixed; 0.5 * ones(2 + pred_num, 1)];
f_random = @(x)KN_HeteLLH(x, matrix, pred_num, choice_max, draws);
ops_random = optimoptions(@fminunc, 'Algorithm', 'trust-region',...
        'DerivativeCheck', 'off', 'GradObj', 'on', 'HessUpdate', 'bfgs',...
        'Display', 'iter', 'TolX', 1e-9,'TolFun', 1e-9, 'MaxIter', 500,...
        'MaxFunEvals', 1e10, 'FinDiffType', 'central');
[par_random, fval_random, exitflag_random, output_random, grad_random, hess_random]...
    = fminunc(f_random, random0, ops_random);
SE = sqrt(diag(inv(hess_random)));

% beta_mu: 1---pred_num; gamma_mu: pred_num+1---pred_num+choice; 
% delta_mu: pred_num+choice+1--pred_num+2*choice
% beta_sigma: pred_num+2*choice+1---2*pred_num+2*choice
% gamma_sigma: 2*pred_num+2*choice+1---2*pred_num+3*choice
% delta_sigma: 2*pred_num+3*choice+1---2*pred_num+4*choice
rbeta_mu  = par_random(1:pred_num); 
rgamma_mu = par_random(pred_num+1:pred_num+choice_max); 
rdelta_mu = par_random(pred_num+choice_max+1);

rbeta_sigma = exp(par_random(pred_num+2*choice_max+1:...
    2*pred_num+2*choice_max));
rgamma_sigma = exp(par_random(2*pred_num+2*choice_max+1));
rdelta_sigma = exp(par_random(end));

figure(3); scatter(beta_mu, rbeta_mu);
figure(4); scatter([gamma_mu;delta_mu], [rgamma_mu;rdelta_mu]);
figure(5); scatter([beta_sigma;gamma_sigma;delta_sigma], ...
    [rbeta_sigma;rgamma_sigma;rdelta_sigma]);
save data.mat
