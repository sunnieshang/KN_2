clc; 
clearvars; 
rng('shuffle'); 
T         = 365; 
nvip      = 99; 
route_min = 1; 
route_max = 10;
vip_route = datasample(route_min:route_max, nvip)';

%%  Meaning                 
% 1.  T: # of time windows in the year 2013
% 2.  nvip: # of shipping customers 
% 3.  route_min, route_max: the lower/upper bound of the frequent routes of
%         each customer. I limit the upper bound using route_max.
% 4.  vip_route: nvip*1 vector, recording the # of frequent routes of each
%         vip
% 5.  pred_num: number of normal predictors
% 6.  serq_num: number of service quality predictors 
% 7.  Parameters (gamma, lambda, delta, beta, mu, phi, nu, a, b, zeta,
%         kappa, gamma_mu etc.) are explained in the next section
% 8.  prior_mat:1-max_route, mu_r; max_route+1: zeta (level 2, high); 
%         max_route+2, kappa (level 2); max_route+3, phi_a; max_route+4, phi_b; 
%         max_route+5, nu_phi (level 1, low);
%         max_route+6: mu_beta=0; max_route+7: phi_beta. 
% 9.  Exp_mat: this is the expectation matrix, including statistics to be
%         used in the indirect utility function. The content of this matrix
%         can be changed according to model specification (which metrics to 
%         be used in the indirect utility function, only mean or mean+var or 
%         mean+sd etc. 
% 10. ID_mat: 1, Vip ID; 2, Period (1 to T, the same for everyone); 
%         3, route index; 4, price; 5, real experience; 6, expected 
%         experience; 7, shipped or not  
% 11. U_mat: utility matrix 1. V; 2, EV; 3, EV/(1+EV);
%         4, lambda*EV/(1+EV)

%% Parameter and Model Specification
% U = gamma + beta*data_predictor
% gamma ~ N(gamma_mu, gamma_sigma)
% lambda = exp(delta)/(1+exp(delta))----->delta ~ N(delta_mu, delta_sigma)
% Note: lambda is the arrival rate. The arrival rate should be less than 1
%       so that our model can handle the situation that people don't arrive
%       everyday. 
% beta  ~ N(beta_mu, beta_sigma)
% Indirect Utiltiy = beta_1*pred_1 + 
%     beta_2*E(service_quality|route r, customer i)
% service quality: log((actual-planned)/planned shipping duration) 
%     ~ N(mu, phi), where mu ~ N(nu, xi), phi ~ G(a, b), nu ~ N(zeta, kappa)

%% Bayesian parameter update flow
% 1. When t=1:
%     1.1 Let E(service quality) = mu
%     1.2 Arrival rate AR= lambda * e(U)/(1+e(U)), where
%         U = beta_1*pred_1+beta_2*E(service quality)
%     1.3 Calcuate the arrival gap for each customer, gap~exp(AR)
%     1.4 Update the arrival matrix
% 2. When t>1: 
%     2.1 Update E(service quality) by using the real shipping quality from
%         the last time.
%     2.(2,3,4) are the same as 1.(2,3,4)

%% Simulate parameters
% Note: gamma cannot vary too much, beta can!!!
gamma_mu    = normrnd(0, 1, [1, 1]);
gamma_sigma = 0.15; 
gamma       = normrnd(repmat(gamma_mu', nvip, 1), ...
                      gamma_sigma, ...
                      [nvip, 1]);

delta_mu    = normrnd(0.3, 0.1, [1, 1]);
delta_sigma = 0.1;
delta       = normrnd(repmat(delta_mu', nvip, 1), ...
                      delta_sigma, ...
                      [nvip, 1]);

lambda      = exp(delta)./(1+exp(delta));

pred_num    = 1; 
serq_num    = 1; % service quality predictor 

beta_mu     = [-1; 1.2]; 
beta_sigma  = [0.25; 0.2];
beta        = normrnd(repmat(beta_mu', nvip, 1), ...
                      repmat(beta_sigma', nvip, 1), ...
                      [nvip, pred_num+serq_num]); 

% NOTE 1: should scall all X var to have mean 0 and std 1
% Note 2: check rcond: <1e-16 is a sig problem: drop or combine var
prior_mat   = KN_Prior(vip_route, 0);
% Exp_ma is the expectation matrix used into utitlity function for decision
% making
Exp_mat     = KN_Exp(prior_mat, 0);
ID_mat      = KN_ID(vip_route, T);
U_mat       = zeros(nvip, 4);
T_index     = (0: T: T*(nvip-1))';

%% predictors updates by period
for t = 1:T
    % Make decision based on current info
    T_index     = T_index + 1; 
    U_mat(:, 1) = ...
        KN_IndUtility(T_index, gamma, beta, ID_mat);
    U_mat(:, 2) = exp(U_mat(:, 1));
    U_mat(:, 3) = U_mat(:, 2)./(U_mat(:, 2) + 1);
    U_mat(:, 4) = lambda .* U_mat(:, 3);
    ID_mat(T_index, 7) = binornd(1, U_mat(:, 4));
    
    % Update believes after real experiences
<<<<<<< HEAD:KN_Simu.m
    Exp_mat = KN_BUpdate(T_index, ID_mat, prior_mat, Exp_mat, vip_route);
=======
    Exp_mat     = ...
        KN_BUpdate(T_index, ID_mat, prior_mat, Exp_mat);
>>>>>>> 583e2e3e23b6f089c3245f838428846cd603a7a2:KN_Simu1.m
    
    % Updatevhuviivnfgciufduictnkbhtfgbcvevc believes for the next period
    ID_mat(T_index+1, 6) = ...
        Exp_mat(sub2ind(size(Exp_mat), ...
                       (1: 1: nvip)',...
                        ID_mat(T_index+1, 3)));
end
clear i;
save data.mat; 

