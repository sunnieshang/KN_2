% Estimate 15: Ind + symmetric
clc; clearvars; rng('shuffle');
load Learning_Ind.mat % P_mat and Pred_mat (Complete_mat) are scaled by 1000, 4000 
Vip_route_rate = zeros(nvip, route_max);
clear MExp_mat_95 VExp_mat_95 NPrior_mat NPrior_mat1 ...
    T_index DIC LL i nDIC nLL Prior_mat t n_continuous Complete_mat
Complete_mat_fill = csvread('Exp_mat_fill.csv', 1, 0); % direct memory from past experiences
Utility_Pred = csvread('Utility_Pred.csv', 1, 0); % chargeable weight, Q3, Q4
Trend_mat = Complete_mat_fill - MExp_mat(:, 1:route_max);
VExp_mat = 1./sqrt(VExp_mat);
VExp_mat(isinf(VExp_mat)) = 0;
Utility_Pred(:, 2) = (Utility_Pred(:, 2)-20)/12;

%% Sample Customer for Shorter Computation Time
% nvip = 50; %can adjust this sample value
Vip_route = Vip_route(1: nvip);
Start_mat = Start_mat(1: nvip*T, :);
%% The follows are used as predictors, normalize
P_mat = (P_mat(1: nvip*T, :) - 1)/5;
logP_mat = (logP_mat(1: nvip*T, :)-5.5)/1.4;
Pred_mat = (Pred_mat(1: nvip*T, :)-2)/0.9;
MExp_mat = MExp_mat(1: nvip*T, :)/2; 
VExp_mat = VExp_mat(1: nvip*T, :);
% VExp_mat = VExp_mat - repmat(mean(VExp_mat), size(VExp_mat,1),1);
% VExp_mat = VExp_mat./repmat(std(VExp_mat), size(VExp_mat,1),1);
% Complete_mat_fill = Complete_mat_fill(1: nvip*T, :)/2.8;
Utility_Pred = Utility_Pred(1: nvip*T, :);
Utility_Pred(:, 1) = (Utility_Pred(:, 1) - 800)/3000;
% Trend_mat = Trend_mat(1: nvip*T, :);
% Trend_mat = Trend_mat/2.5; 

%% For all the matrix, need to use the post_sample
index = T_pre+1:T;
for i = 1: nvip-1
    index = [index, T*i+(T_pre+1:T)];
end
P_mat = P_mat(index,:);
logP_mat = logP_mat(index,:);
Pred_mat = Pred_mat(index,:);
MExp_mat = MExp_mat(index,:); 
VExp_mat = VExp_mat(index,:);
Complete_mat_fill = Complete_mat_fill(index,:);
Utility_Pred = Utility_Pred(index,:);
Start_mat = Start_mat(index, :);
Start_mat(:, 2) = Start_mat(:, 2) - T_pre;
% Trend_mat = Trend_mat(index,:);
T = T - T_pre;
clear i index T_pre;
%% Parameter and Model Specification
% Start_mat: 1, child_id; 2, start period; 3, route_id; 4, logP; 5, ship or
% not
% U_mat: utility matrix 1. V; 2, EV; 3, EV/(1+EV); 4, lambda*EV/(1+EV)
% EU = gamma + beta*data_predictor
% gamma ~ N(gamma_mu, gamma_sigma)
% Not Userd Currently: lambda = exp(delta)/(1+exp(delta))----->delta ~ N(delta_mu, delta_sigma)
%     Note: lambda is the arrival rate. The arrival rate should be less than 1
%         so that our model can handle the situation that people don't arrive
%         everyday. Currenly the lambda is not used. Instead, we use a
%         multinomial distribution for the route each customer choose in each
%         period among all the possible routes of this specific customer
% beta  ~ N(beta_mu, beta_sigma)
% Indirect Utiltiy = beta_1*pred_1 + 
%     beta_2*E(service_quality|route r, customer i)

%% Generate service matrics
Q_mat(:,:,1) = MExp_mat(:, 1:route_max);
%% Generate other predictors X, the same for all the customers
X(:, :, 1) = logP_mat;
%X(:, :, 2) = Pred_mat; % distance
X(:, :, 2) = repmat(Utility_Pred(:,1), 1, route_max); % weight
X(:, :, 3) = repmat(Utility_Pred(:,2), 1, route_max); % total shipping periods
X(:, :, 4) = repmat(Utility_Pred(:,3), 1, route_max); % Q3
X(:, :, 5) = repmat(Utility_Pred(:,4), 1, route_max); % Q4
% have tested the potential correlation between price, distance and weight
% A = [Utility_Pred(:, 1), logP_mat(:, 1), P_mat(:, 1), Pred_mat(:, 1)]; corrcoef(A)
X = cat(3, Q_mat, X, ones(size(Q_mat,1),size(Q_mat,2),1));
% X = cat(3, Complete_mat_fill, X, ones(size(Q_mat,1),size(Q_mat,2),1));
%% Simulate parameters
% NOTE 1: should scall all X var to have mean 0 and std 1
% Note 2: check rcond: <1e-16 is a sig problem: drop or combine var
for i = 1: nvip
    Vip_route_rate(i, 1: Vip_route(i)) = sort(drchrnd(ones(1, Vip_route(i)), 1), 'descend');
    
end
% Note: gamma cannot vary too much, beta can!!!
hete_num = 1; 
homo_num = size(X, 3) - hete_num; 
pred_num = hete_num + homo_num;
beta_mu     = -0.5*ones(1,pred_num);
beta_sigma  = [0.3*ones(1, hete_num), zeros(1, pred_num-hete_num)]; 
beta        = normrnd(repmat(beta_mu, nvip, 1), ...
                      repmat(beta_sigma, nvip, 1), ...
                      [nvip, hete_num + homo_num]); 
T_index     = 1:T:1+(nvip-1)*T;
% SStart_mat = Start_mat; % simulated Start_mat
% for i=1:nvip
%     SStart_mat((i-1)*T+1: i*T, 3) = sum(mnrnd(ones(T, 1), Vip_route_rate(i, :)) ...
%         .* repmat(1: route_max, T, 1), 2);
% end
% 
% %% Simulate Purchase Choices
% IndU = KN_IndUtility(1:T*nvip, beta, X, Vip_route);
% IndU = exp(IndU); 
% IndU = IndU ./ (1 + IndU);
% Prob = IndU(sub2ind(size(IndU), (1:nvip*T)', SStart_mat(:, 3))); 
% SStart_mat(:, 5) = binornd(1, Prob);

%% Estimation Homogeneous
nfixed = pred_num + sum(Vip_route) - nvip; % beta (vip*k); gamma (veggie)
fixed0 = rand(nfixed, 1); 
f_fixed = @(x)KN_HomoLLH(x,...
                         Start_mat,...
                         pred_num,...
                         Vip_route, ...
                         X);
% if check derivative, use "central finite difference", more accurate than
% the default forward finite deifference". 
% The estimation finished in around 30 minutes for 9 customers in 180
% periods and 22% of positive period (sum(Start_mat(:,7))/size(Start_mat, 1))
ops_fixed = optimoptions(@fminunc, 'Algorithm', 'trust-region',...
        'DerivativeCheck', 'off', 'GradObj', 'on', 'Display', 'iter', ...
        'TolX', 1e-9, 'TolFun', 1e-9, 'MaxIter', 1000, ...
        'MaxFunEvals', 1e10, 'FinDiffType', 'forward', 'MaxIter', 100);
[par_fixed, fval_fixed, exitflag_fixed, output, grad, hess] = ...
    fminunc(f_fixed, fixed0, ops_fixed);
fixed_SE = sqrt(diag(inv(hess)));
fixed_beta  = par_fixed(1: pred_num);
index = pred_num + 1;
fixed_rate = zeros(nvip, route_max);
figure;
for i = 1: nvip
    fixed_rate(i, 1) = 1/ ...
        (1 + sum(exp(par_fixed(index: (index+Vip_route(i)-2)))));
    fixed_rate(i, 2: Vip_route(i)) = exp(par_fixed(index:index+Vip_route(i)-2)) ...
        ./ (1 + sum(exp(par_fixed(index: (index+Vip_route(i)-2)))));
    index = index + Vip_route(i) - 1; 
    hold on;
    scatter(fixed_rate(i, :), Vip_route_rate(i, :));
end
figure(2);
scatter(fixed_beta, beta_mu);
fixed_rate(:, route_max+1) = max(fixed_rate, [], 2);
fixed_rate(fixed_rate==0)=1;
fixed_rate(:, route_max+2) = min(fixed_rate, [], 2);
mean(fixed_rate(:, end-1: end))
quantile(fixed_rate(:, end-1: end), [0.05, 0.95])
% fixed0 = par_fixed;
save R15.mat

%% Heterogeneous Parameters Estimation
%% Create draws to be used in estimation
% let's follow STATA in using 50 Halton draws per consumer for primes 2 and 3, dropping the first 15 (burn) 
% ndraws = 100;
% haltondraws = haltonset(hete_num, 'Skip', 50);
% haltondraws = scramble(haltondraws, 'RR2'); 
% draws = zeros(nvip, hete_num, ndraws);
% for i=1: hete_num
%      draws(:, i, :) = reshape(norminv(haltondraws(1: nvip*ndraws, i), 0, 1), ...
%          nvip, ndraws);
% end
% 
% %% Recover/Estimate random coefficient
% nrandom = nfixed + hete_num; % plus STD for each beta and gamma
% random0 = [par_fixed; -1 * ones(hete_num, 1)];
% f_random = @(x)KN_HeteLLH(x, Start_mat, pred_num, hete_num, ...
%     Vip_route, X, draws);
% ops_random = optimoptions(@fminunc, 'Algorithm', 'trust-region',...
%     'DerivativeCheck', 'off', 'GradObj', 'on', ...
%     'Display', 'iter', 'TolX', 1e-9,'TolFun', 1e-9, 'MaxIter', 100,...
%     'MaxFunEvals', 1e10, 'FinDiffType', 'forward');
% [par_random, fval_random, exitflag_random, output_random, grad_random, hess_random]...
%     = fminunc(f_random, random0, ops_random);
% rSE = sqrt(diag(inv(hess_random)));
% 
% rbeta_mu = par_random(1: pred_num); 
% rbeta_sigma = exp(par_random(end - (hete_num) + 1 : end));
% rrate = zeros(nvip, route_max);
% figure(3)
% index = pred_num + 1; 
% for i = 1: nvip
%     rrate(i, 1) = 1/ ...
%         (1 + sum(exp(par_random(index: (index+Vip_route(i)-2)))));
%     rrate(i, 2: Vip_route(i)) = exp(par_random(index: index+Vip_route(i) - 2)) ...
%         ./ (1 + sum(exp(par_random(index: (index + Vip_route(i)-2)))));
%     index = index + Vip_route(i) - 1; 
%     hold on;
%     scatter(rrate(i, :), Vip_route_rate(i, :));
% end
% figure(4);
% scatter(beta_mu, rbeta_mu);
% figure(5);
% scatter(beta_sigma(1:hete_num), rbeta_sigma);
% random0 = par_random;
% save R15.mat
