clc; clearvars; rng('shuffle'); 
T = 180; 
nvip = 9; 
route_min = 2; 
route_max = 5;
pred_num = 1; 
serq_num = 1; % service quality predictor 
n_continuous = 0;
vip_route = datasample(route_min: route_max, nvip)';
vip_route_rate = zeros(nvip, route_max);
for i = 1: nvip
    vip_route_rate(i, 1: vip_route(i)) = drchrnd(ones(1, vip_route(i)), 1);
end
%% NOTE from Andres
% Look at the data and find the customers having more than 1 route demand
% in one period. Another option: a predefined number of shipments in every
% period, which is customer specific.
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
% 8.  prior_mat:1: zeta (level 2, high); 2, kappa (level 2); 3, phi_a; 
%         4, phi_b; 5, nu_phi (level 1, low); 6: alpha_mu=0; 7: alpha_phi. 
% 9.  Exp_mat: this is the expectation matrix, including statistics to be
%         used in the indirect utility function. The content of this matrix
%         can be changed according to model specification (which metrics to 
%         be used in the indirect utility function, only mean or mean+var or 
%         mean+sd etc. Current, the size is nvip*(route_max+1) where 
%         nvip*route_max are the mu_i, and nvip*1 is the std
% 10. ID_mat: 1, vip id; 2, period (1 to T, the same for everyone); 
%         3, route index; 4, price; 5, real experience; 6, expected 
%         experience; 7, shipped or not  
% 11. U_mat: utility matrix 1. V; 2, EV; 3, EV/(1+EV);
%         4, lambda*EV/(1+EV)

%% Parameter and Model Specification
% EU = gamma + beta*data_predictor
% gamma ~ N(gamma_mu, gamma_sigma)
% lambda = exp(delta)/(1+exp(delta))----->delta ~ N(delta_mu, delta_sigma)
% Note: lambda is the arrival rate. The arrival rate should be less than 1
%       so that our model can handle the situation that people don't arrive
%       everyday. 
% beta  ~ N(beta_mu, beta_sigma)
% Indirect Utiltiy = beta_1*pred_1 + 
%     beta_2*E(service_quality|route r, customer i)
% service quality: y=(actual-planned)/planned shipping duration
%     ~ N(categ_pred+alpha*conti_pred, phi), mu_ir is one of the
%     categorical predictor (currently only consider one categorial
%     predictor)
% where mu_ir ~ N(nu_i, nu_phi), phi ~ G(a, b), nu_i ~ N(zeta, kappa)
% nu_i is the hyperparameter, alpha ~ N(alpha_mu, alpha_phi)

%% Bayesian parameter update flow
% 1. When t=1:
%     1.1 Let E(service quality) = Exp_mat
%     1.2 Arrival rate AR= lambda * e(U)/(1+e(U)), where
%         U = beta_1*pred_1+beta_2*E(service quality)
% TODO: 1.3 is not realized yet, need to discuss with Andres about it
%     1.3 Calcuate the arrival gap for each customer, gap~exp(AR)
%     1.4 Update the arrival matrix
% 2. When t>1: 
%     2.1 Update E(service quality) by using the real shipping quality from
%         the last time.
%     2.(2,3,4) are the same as 1.(2,3,4)

%% Simulate parameters
% Note: gamma cannot vary too much, beta can!!!
% gamma_mu    = normrnd(0.5, 1, [1, 1]);
gamma_mu    = 0.8; 
gamma_sigma = 0.15; 
gamma       = normrnd(repmat(gamma_mu', nvip, 1), ...
                      gamma_sigma, ...
                      [nvip, 1]);
% delta_mu    = normrnd(0.3, 0.1, [1, 1]);
% delta_sigma = 0.1;
% delta       = normrnd(repmat(delta_mu', nvip, 1), ...
%                       delta_sigma, ...
%                       [nvip, 1]);
% lambda      = exp(delta) ./ (1 + exp(delta));
% lambda = ones(nvip, 1); 

beta_mu     = [-1; 0.15]; 
beta_sigma  = [0.25; 0.02];
beta        = normrnd(repmat(beta_mu', nvip, 1), ...
                      repmat(beta_sigma', nvip, 1), ...
                      [nvip, pred_num + serq_num]); 

% NOTE 1: should scall all X var to have mean 0 and std 1
% Note 2: check rcond: <1e-16 is a sig problem: drop or combine var
prior_mat   = KN_Prior(n_continuous, nvip);
% Exp_mat is the expectation matrix used into utitlity function for decision
% making
Exp_mat     = KN_Exp(prior_mat, n_continuous, route_max);
ID_mat      = KN_ID(vip_route_rate, T);
U_mat       = zeros(nvip, 4);
T_index     = (0: T: T*(nvip-1))';

%% predictors updates by period
for t = 1:T
    % Make decision based on current info
    T_index     = T_index + 1; 
    IndU = KN_IndUtility(T_index, gamma, beta, Exp_mat, ID_mat);
    U_mat(:, 1) = IndU(...
        sub2ind(size(IndU), (1: 1: nvip)', ID_mat(T_index, 3)));
    U_mat(:, 2) = exp(U_mat(:, 1));
    U_mat(:, 3) = U_mat(:, 2)./(U_mat(:, 2) + 1);
%     U_mat(:, 4) = lambda .* U_mat(:, 3);
    U_mat(:, 4) = U_mat(:, 3);
    ID_mat(T_index, 7) = binornd(1, U_mat(:, 4));   
    % Update believes after real experiences
    Exp_mat = KN_BUpdate(T_index, ID_mat, prior_mat, Exp_mat, vip_route); 
end
clear i;
save data.mat; 


