function [prior] = KN_Prior(n_continuous, nvip)
% service quality: y=(actual-planned)/planned shipping duration
%     ~ N(categ_pred+alpha*conti_pred, phi), mu_ir is one of the
%     categorical predictor (currently only consider one categorial
%     predictor)
% where mu_r ~ N(nu, nu_phi), phi ~ G(a, b), nu ~ N(zeta, kappa)
% nu_i is the hyperparameter, alpha ~ N(alpha_mu, alpha_phi)
% prior_mat:1: zeta (level 2, high); 2, kappa (level 2); 3, phi_a; 
%     4, phi_b; 5, nu_phi (level 1, low); 6: alpha_mu=0; 7: alpha_phi. 
    prior = zeros(nvip, 5+2*n_continuous); 
    prior(:,2) = 1/(30^2); 
    prior(:,3) = 1.05; prior(:,4) = 10; 
    prior(:,5) = 1.05; prior(:,6) = 3; 
    if (n_continuous>0)
        for i = 1: n_continuous
            prior(:, 6+2*i) = 1/(30^2);
        end
    end
end