function [post_mat, ID, route] = KN_BUpdate(T_index, ...
                                            ID_mat, ...
                                            pred_mat, ...
                                            prior_mat, ...
                                            route_max)
    post_mat = prior_mat;
    T_update  = T_index(ID_mat(T_index, 3)==1); 
    ID        = ID_mat(T_update, 1); 
    route     = pred_mat(T_update, 2);
    iter      = 1000; 
    burnin    = 500; 
    nu        = zeros(iter, length(T_update)); 
    nui       = zeros(iter, length(T_update)); 
    phi       = zeros(iter, length(T_update)); 
    err2      = zeros(iter, length(T_update));
    nu_mu     = zeros(iter, length(T_update)); 
    nui_mu    = zeros(iter, length(T_update)); 
    
    % starting point
    nui(1,:)  = prior_mat(ID, route_max+1);
    phi(1,:)  = gamrnd(prior_mat(ID, route_max+3),...
                         1./prior_mat(ID, route_max+4));
    
    % prior_matrix
    % 1-route_max, nu_j; 1, route_max+1: zeta; 2, route_max+2, kappa; 
    % 3, route_max+3, phi_a; 4, route_max+4, phi_b; 5, route_max+5, nu_phi
    
    % data_predictor
    % 1, vip id; 2, vip route num; 3, experience of vip chosen route for time t;
    % 4, price for the choice; etc (other predictors)
    y        = pred_mat(T_update, 3)';
    
    zeta     = prior_mat(ID, route_max+1)';
    kappa    = prior_mat(ID, route_max+2)';
    phi_a    = prior_mat(ID, route_max+3)';
    phi_b    = prior_mat(ID, route_max+4)';
    nu_phi   = prior_mat(ID, route_max+5)';
    
    % Gibbs sampling
    for i = 2: iter
        nu_mu(i, :) = (nui(i-1, :).*...
                      nu_phi+y.*phi(i-1, :))./...
                      (nu_phi+phi(i-1, :));
        nu(i, :)    = normrnd(nu_mu(i, :), ...
                              1./sqrt(nu_phi+phi(i-1, :)));
        nui_mu(i, :)= (zeta.*kappa + nu(i, :).*nu_phi)./...
                      (kappa+nu_phi);
        nui(i, :)   = normrnd(nui_mu(i, :), ...
                              1./sqrt(kappa+nu_phi));
        err2(i, :)  = (y-nu(i, :)).^2; 
        phi(i, :)   = gamrnd(phi_a+1/2, ...
                             1./(phi_b+1/2*err2(i, :)));        
    end
    % post Gibbs sampling selection
    
    post_mat(sub2ind(size(post_mat), ID, route)) = ...
        mean(nu_mu(burnin:iter, :), 1);
    post_mat(ID, route_max+1) = mean(nui_mu(burnin:iter, :), 1);
    post_mat(ID, route_max+2) = kappa + nu_phi;
    post_mat(ID, route_max+3) = phi_a + 1/2;
    post_mat(ID, route_max+4) = phi_b + 1/2*mean(err2, 1);
    post_mat(ID, route_max+5) = nu_phi + mean(phi(burnin:iter, :), 1);
    
end

