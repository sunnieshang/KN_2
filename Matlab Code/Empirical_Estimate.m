clc; clearvars; rng('shuffle'); 
%% Read In Date
load Learning_Hier.mat;

%% Homogeneous Parameters Estimation
pred_num = 1; 
serq_num = 1;
nfixed = pred_num + serq_num + sum(Vip_route) - nvip + 1; % beta (vip*k); gamma (veggie)
RMExp_mat = MExp_mat(:, 1:end-1);
fixed0 = 0.2 * ones(nfixed, 1); 
% fixed0 = par_fixed;
% fixed0(1:2) = beta_mu';
% fixed0(end) = gamma_mu;
% fixed0(2) = 0.5;
f_fixed = @(x)KN_HomoLLH(x,...
                         Start_mat,...
                         pred_num,...
                         serq_num,...
                         Vip_route, logP_mat, RMExp_mat);
% if check derivative, use "central finite difference", more accurate than
% the default forward finite deifference". 
% The estimation finished in around 30 minutes for 9 customers in 180
% periods and 22% of positive period (sum(ID_mat(:,7))/size(ID_mat, 1))
ops_fixed = optimoptions(@fminunc, 'Algorithm', 'trust-region',...
        'DerivativeCheck', 'off', 'GradObj', 'on', 'Display', 'iter', ...
        'TolX', 1e-9, 'TolFun', 1e-9, 'MaxIter', 1000, ...
        'MaxFunEvals', 1e10, 'FinDiffType', 'forward', 'MaxIter', 100);
[par_fixed, fval_fixed, exitflag_fixed, output, grad, hess] = ...
    fminunc(f_fixed, fixed0, ops_fixed);
fixed_SE = sqrt(diag(inv(hess)));
fixed_beta  = par_fixed(1: pred_num + serq_num);
fixed_gamma = par_fixed(end);
index = serq_num + pred_num + 1;
fixed_rate = zeros(nvip, route_max);
for i = 1: nvip
    fixed_rate(i, 1) = 1/ ...
        (1 + sum(exp(par_fixed(index: (index+Vip_route(i)-2)))));
    fixed_rate(i, 2: Vip_route(i)) = exp(par_fixed(index:index+Vip_route(i)-2)) ...
        ./ (1 + sum(exp(par_fixed(index: (index+Vip_route(i)-2)))));
    index = index + Vip_route(i) - 1; 
end
fixed0 = par_fixed;
save Homo_Result.mat

%% Heterogeneous Parameters Estimation
%% Create draws to be used in estimation
% let's follow STATA in using 50 Halton draws per consumer for primes 2 and 3, dropping the first 15 (burn) 
ndraws = 50;
haltondraws = haltonset(pred_num + serq_num + 1, 'Skip', 15);
haltondraws = scramble(haltondraws, 'RR2'); 
draws = zeros(nvip, pred_num + serq_num + 1, ndraws);
for i=1: pred_num + serq_num + 1
     draws(:, i, :) = reshape(norminv(haltondraws(1: nvip*ndraws, i), 0, 1), ...
         nvip, ndraws);
end

%% Recover/Estimate random coefficient
nrandom = nfixed + pred_num + serq_num + 1; % plus STD for each beta and gamma
random0 = [par_fixed; -1.5 * ones(pred_num + 1, 1)];
f_random = @(x)KN_HeteLLH(x, ID_mat, pred_num, serq_num, ...
    Vip_route, P_mat, RMExp_mat, draws);
ops_random = optimoptions(@fminunc, 'Algorithm', 'trust-region',...
    'DerivativeCheck', 'off', 'GradObj', 'on', ...
    'Display', 'iter', 'TolX', 1e-9,'TolFun', 1e-9, 'MaxIter', 100,...
    'MaxFunEvals', 1e10, 'FinDiffType', 'forward');
[par_random, fval_random, exitflag_random, output_random, grad_random, hess_random]...
    = fminunc(f_random, random0, ops_random);
rSE = sqrt(diag(inv(hess_random)));

rbeta_mu = par_random(1: pred_num + serq_num); 
rbeta_sigma = exp(par_random(end - (pred_num) + 1 : end));
rgamma_mu = par_random(end - 3);
rgamma_sigma = exp(par_random(end - pred_num - serq_num));
rrate = zeros(nvip, route_max);
figure(3)
index = pred_num + serq_num + 1; 
for i = 1: nvip
    rrate(i, 1) = 1/ ...
        (1 + sum(exp(par_random(index: (index+Vip_route(i)-2)))));
    rrate(i, 2: Vip_route(i)) = exp(par_random(index: index+Vip_route(i) - 2)) ...
        ./ (1 + sum(exp(par_random(index: (index + Vip_route(i)-2)))));
    index = index + Vip_route(i) - 1; 
    hold on;
    scatter(rrate(i, :), vip_route_rate(i, :));
end
figure(4);
scatter([beta_mu', gamma_mu], [rbeta_mu', rgamma_mu]);
figure(5);
scatter([beta_sigma', gamma_sigma], [rbeta_sigma', rgamma_sigma]);
random0 = par_random;
save Hete_Result.mat