function [prior] = KN_Prior2(n_continuous, nvip, route_max)
% service quality: y=(actual-planned)/planned shipping duration
%     ~ N(categ_pred+alpha*conti_pred, phi), mu_ir is one of the
%     categorical predictor (currently only consider one categorial
%     predictor)
% where mu_r ~ N(nu, nu_phi), phi ~ G(a, b), nu ~ N(zeta, kappa)
% nu_i is the hyperparameter, alpha ~ N(alpha_mu, alpha_phi)
% prior_mat:1: zeta (level 2, high); 2, kappa (level 2); 3, phi_a; 
%     4, phi_b; 5, nu_phi (level 1, low); 6: alpha_mu=0; 7: alpha_phi. 
    prior = zeros(nvip, route_max + 4 + 2*n_continuous);
    prior(:,1:route_max) = 1/(20^2); 
    prior(:,route_max + 2) = 1/(5^2); % for hyper-parameter, mu and phi
    prior(:,route_max + 3) = 1.05; prior(:,route_max + 4) = 10; % for experience variability
    
    if (n_continuous>0)
        for i = 1: n_continuous
            prior(:, 6+2*i) = 1/(30^2);
        end
    end
end