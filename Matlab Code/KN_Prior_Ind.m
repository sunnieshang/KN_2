function [prior] = KN_Prior_Ind(route_max, nvip)
% service quality: y=(actual-planned)/planned shipping duration
%     ~ N(categ_pred+alpha*conti_pred, phi), mu_ir is one of the
%     categorical predictor (currently only consider one categorial
%     predictor)
% where mu_r ~ N(nu, nu_phi), phi ~ G(a, b), nu ~ N(zeta, kappa)
% nu_i is the hyperparameter, alpha ~ N(alpha_mu, alpha_phi)
% prior_mat:1: zeta (level 2, high); 2, kappa (level 2); 3, phi_a; 
%     4, phi_b; 5, nu_phi (level 1, low); 6: alpha_mu=0; 7: alpha_phi. 
    prior = zeros(nvip, 2*route_max+2); 
    prior(:,route_max+1:2*route_max) = 1/(30^2); 
    prior(:, end-1) = 1.05; prior(:,end) = 10; 
end