clc; clearvars; rng('shuffle'); 
%% Read In Date
Complete_mat = csvread('Exp_mat_tocountry.csv', 1, 0);
% 1, child_id; 2, complete_period; 3, route_1; 4, delay_1; 
% 5, route_2; 6, delay_2; 7, r_3; 8, d_3, 9, r_4, 10, d_4, 11, r_5, 12, d_5, 
% 13, r_6; 14, d_6,15, r_7; 16, d_7; 17, complete or not
Vip_route = csvread('Child_Route_Num_tocountry.csv', 1, 0)'; % nvip * 1
P_mat = csvread('P_mat_tocountry.csv'); 
logP_mat = csvread('logP_mat_tocountry.csv');
Start_mat = csvread('ID_mat_tocountry.csv'); 
% Start_mat: 1, child_id; 2, start period; 3, route_id; 4, ship or not
Pred_mat = csvread('Predictor_tocountry.csv');
Start_mat(:, 5) = Start_mat(:, 4);
Start_mat(Start_mat(:, 3)==0, 3) = 1;
Start_mat(:, 4) = logP_mat(sub2ind(size(P_mat), (1:1:size(Start_mat,1))', Start_mat(:, 3))); 
% logP_mat = (logP_mat - mean(mean(logP_mat)))/1.5;
T = 103; % 3.5 days period 

%% Normalization 
Pred_mat = Pred_mat/4000;
Complete_mat(:, end) = Complete_mat(:, end)/4000;
P_mat = P_mat/1000;

%% Sample Customer
% c_min = 0; c_max = 50;
% Vip_route = Vip_route(c_min + 1: c_max);
% Complete_mat = Complete_mat(Complete_mat(:, 1)>c_min & Complete_mat(:, 1)<=c_max,:);
% P_mat = P_mat(c_min*T + 1: c_max*T, :);
% logP_mat = logP_mat(c_min*T + 1: c_max*T, :);
% Pred_mat = Pred_mat(c_min*T + 1: c_max*T, :);
% Start_mat = Start_mat(c_min*T + 1: c_max*T, :);

%% Bayesian Learning of the shippers' experiences (2 hours on Latte for 122 periods)
T_pre = 24;
nvip = size(P_mat, 1)/T;
route_min = 2; 
route_max = 4;
n_continuous = 1;
Prior_mat   = KN_Prior_Ind(route_max, nvip);
NPrior_mat = Prior_mat;
T_index = (1: T: T*(nvip-1)+1)';
MExp_mat = zeros(nvip*T, route_max); % mean experience mat
MExp_mat_95 = zeros(nvip*T, 2*route_max); % 95% confidence interval
VExp_mat = zeros(nvip*T, 1 + route_max); % variance experience mat 
VExp_mat_95 = zeros(nvip*T, 2); % 95% confidence interval
VExp_mat(T_index, :) = 1/30^2;
%% Pre-estimation to Update the Priors for each customer
for t = 1: T_pre
    display(t);
    [MExp_mat(T_index+1, :), ...
     VExp_mat(T_index+1, :), ...
     NPrior_mat, ...
     MExp_mat_95(T_index+1, :), ...
     VExp_mat_95(T_index+1, :)] = KN_BUpdate_Ind(T_index, ...
                                             Complete_mat, ...
                                             Prior_mat, ...
                                             MExp_mat(T_index, :), ...
                                             VExp_mat(T_index, :), ...
                                             Vip_route, ...
                                             NPrior_mat,...
                                             MExp_mat_95(T_index, :), ...
                                             VExp_mat_95(T_index, :));
    T_index = T_index + 1;
end

%% Full model for learning
Prior_mat = NPrior_mat;
LL = 0; DIC = 0;
for t = T_pre+1: T-1
    display(t);
    [MExp_mat(T_index+1, :), ...
     VExp_mat(T_index+1, :), ...
     NPrior_mat, ...
     MExp_mat_95(T_index+1, :), ...
     VExp_mat_95(T_index+1, :), nLL, nDIC] = KN_BUpdate_Ind(T_index, ...
                                             Complete_mat, ...
                                             Prior_mat, ...
                                             MExp_mat(T_index, :), ...
                                             VExp_mat(T_index, :), ...
                                             Vip_route, ...
                                             NPrior_mat,...
                                             MExp_mat_95(T_index, :), ...
                                             VExp_mat_95(T_index, :));
    LL = LL + nLL; DIC = DIC + nDIC;
    T_index = T_index + 1;
end
save Learning_Ind_tocountry.mat