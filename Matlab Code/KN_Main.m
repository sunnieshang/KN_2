clc; clearvars; rng('shuffle'); 
%% Read In Date
Complete_mat = csvread('Exp_mat.csv', 1, 0);
% 1, child_id; 2, complete_period; 3, delay_1; 4, route_1;
% 5, delay_2; 6, route_2; 7, d_3, 8, r_3; 9, d_4, 10, r_4, 11, d_5, 
% 12, r_5, 13, d_6, 14, r_6; 15, d_7; 16, r_7; 17, complete or not
vip_route_num = csvread('Child_Route_Num.csv', 1, 0); % nvip * 1
P_mat = csvread('P_mat.csv');
Start_mat = csvread('ID_mat.csv'); % 1, child_id; 2, start period; 3, route_id; 4, ship or not
Pred_mat = csvread('Predictor.csv');

%% Recover Necessary Variables
% Exp_mat:this is the expectation matrix, including statistics to be
%         used in the indirect utility function. The content of this matrix
%         can be changed according to model specification (which metrics to 
%         be used in the indirect utility function, only mean or mean+var or 
%         mean+sd etc. Current, the size is nvip*(route_max+1) where 
%         nvip*route_max are the mu_i, and nvip*1 is the std
% ID_mat: 1, vip id; 2, start period (1 to T, the same for everyone); 
%         3, route index; 4, ship or not
% 4, price; 5, real experience; 6, expected 
%         experience; 7, shipped or not  
% U_mat: utility matrix 1. V; 2, EV; 3, EV/(1+EV);
%         4, lambda*EV/(1+EV)
T = 122; 
nvip = size(P_mat, 1)/T; 
route_min = 2; 
route_max = 10;
pred_num = 1; 
serq_num = 1; % service quality predictor 
n_continuous = 0;
vip_route = vip_route_num';
prior_mat   = KN_Prior(n_continuous, nvip);
U_mat       = zeros(nvip, 4);
T_index = (1: T: T*(nvip-1)+1)';
MExp_mat = zeros(nvip*T, route_max); % mean experience mat
VExp_mat = zeros(nvip*T, 1); % variance experience mat
[MExp_mat(T_index, :), VExp_mat(T_index, :)] = KN_Exp(prior_mat, n_continuous, route_max);
for t = 1:T-1
    [MExp_mat(T_index+1, :), VExp_mat(T_index+1, :)] = ...
        KN_BUpdate(T_index, ID_mat, prior_mat, ...
        MExp_mat(T_index, :), VExp_mat(T_index, :), vip_route);
    T_index = T_index + 1;
end