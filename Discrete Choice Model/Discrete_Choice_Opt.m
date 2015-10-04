%% Use fixed coefficient model to find the starting point of random C model
clc; clear var; close all; rng('shuffle'); 
load data.mat;
% 1, trip; 2, vip; 3, choice; 4, veggieid; 5, period; 6, price; 7, fresh
% 8. V; 9, EV; 10, sum(EV) each trip; 11, prob of each trip
nfixed = pred_num + veggie_max; % beta (vip*k); gamma (veggie)
fixed0 = 0.5*ones(nfixed,1);
f_fixed = @(x)KN_SingleLLH(x, matrix,pred_num,veggie_max);
% if check derivative, use "central finite difference", more accurate than
% the default forward finite deifference". 
ops_fixed = optimoptions(@fminunc, 'Algorithm','trust-region',...
        'DerivativeCheck','off','GradObj','on','Display','iter','TolX',1e-9,...
        'TolFun',1e-9, 'MaxIter', 500, 'MaxFunEvals', 1e10,...
        'FinDiffType','central');
[par_fixed, fval_fixed, exitflag_fixed] = fminunc(f_fixed, fixed0, ops_fixed);
fixed_beta  = par_fixed(1:pred_num);
fixed_gamma = par_fixed(pred_num+1:end);
figure(1); scatter(beta_mu, fixed_beta);
figure(2); scatter(gamma_mu, fixed_gamma);

%% Create draws to be used in estimation
% let's follow STATA in using 50 Halton draws per consumer for primes 2 and 3, dropping the first 15 (burn) 
ndraws=50;
haltondraws = haltonset(veggie_max+pred_num,'Skip',15);
haltondraws = scramble(haltondraws,'RR2'); 
draws = zeros(vip,veggie_max+pred_num, ndraws);
for i=1:1:veggie_max+pred_num
     draws(:,i,:) = reshape(norminv(haltondraws(1:vip*ndraws,1),0,1),vip,ndraws);
end
draws(:,veggie_max+pred_num+1,:) = zeros(vip,ndraws);
%% Recover random coefficient
nrandom = nfixed + 1 + pred_num; % plus STD: 1 for gamma; k for beta
random0 = [par_fixed; 0.5*ones(1+pred_num,1)];
f_random = @(x)KN_RandomLLH(x, matrix,pred_num,veggie_max,draws);
ops_random = optimoptions(@fminunc, 'Algorithm','trust-region',...
        'DerivativeCheck','off','GradObj','off','HessUpdate','bfgs',...
        'Display','iter','TolX',1e-9,...
        'TolFun',1e-9, 'MaxIter', 500, 'MaxFunEvals', 1e10,...
        'FinDiffType','central');
[par_random, fval_random, exitflag_random, output_random, grad_random, hess_random]...
    = fminunc(f_random, random0, ops_random);
SE = sqrt(diag(inv(hess_random)));

rbeta_mu  = par_random(1:pred_num); 
rbeta_sigma = par_random(pred_num+veggie_max+1:pred_num+veggie_max+pred_num);
rgamma_mu = par_random(pred_num+1:pred_num+veggie_max); 
rgamma_sigma = par_random(pred_num+veggie_max+pred_num+1:end);
figure(3); scatter(beta_mu, rbeta_mu);
figure(4); scatter(gamma_mu, rgamma_mu);
figure(5); scatter([beta_sigma;gamma_sigma], [rbeta_sigma;rgamma_sigma]);

