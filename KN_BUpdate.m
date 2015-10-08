function Exp_mat = KN_BUpdate(T_index, ID_mat, prior_mat, Exp_mat, vip_route)
    
%% Parameter initialization
    T_update = T_index(ID_mat(T_index, 7)==1); %refer to line 29 in KN_simu.m
    ID = ID_mat(T_update, 1); 
    iter = 1000; 
    burnin = 500; 
    route_max = max(vip_route); 
    nu = zeros(iter, 1); 
    phi = zeros(iter, 1);
    for i = 1: length(T_update)
        %% Priors 
        zeta = prior_mat(ID(i), route_max+1)';
        kappa = prior_mat(ID(i), route_max+2)';
        phi_a = prior_mat(ID(i), route_max+3)';
        phi_b = prior_mat(ID(i), route_max+4)';
        nu_phi = prior_mat(ID(i), route_max+5)';
        beta_mu = prior_mat(ID(i), route_max+6);
        beta_phi = prior_mat(ID(i), route_max+7);
        y = ID_mat(ID_mat(:,1)==ID(i) & ID_mat(:,7)==1, 5);
        categ_mat = ID_mat(ID_mat(:,1)==ID(i) & ID_mat(:,7)==1, 3);
        conti_mat = zeros(size(categ_mat,1),0);
        n_category = size(categ_mat, 2);
        n_continuous = size(conti_mat, 2);
        % ID_mat: 3, route index; 4, price, 5, real experience, 7, ship or not
        levels_in_category = zeros(1, size(categ_mat, 2));
        sub = zeros(1, size(categ_mat, 2)+1);
        levels_in_category(1) = vip_route(ID(i));
        n_obs = zeros(1, sum(levels_in_category));
        sum_obs = zeros(1, sum(levels_in_category));
        for k = 1: n_category
            if (k==1) 
                sub(k) = 0;
            else
                sub(k) = sub(k-1)+levels_in_category(k-1);
            end
            for j = 1: levels_in_category(k)
                n_obs(sub(k)+j) = sum(categ_mat(:, k) == j);
                sum_obs(sub(k)+j) = sum(y(categ_mat(:, k) == j));
            end
        end
        sub(end) = sub(end-1) + levels_in_category(end);
        N = length(y);
        %% Using the last expectation as starting point to reduce burnin    
        mu = zeros(iter, sum(levels_in_category)+n_continuous);
        mu(1, 1:sum(levels_in_category)) = ...
            Exp_mat(ID(i), 1:sum(levels_in_category));
        mu(1, (sum(levels_in_category)+1):(sum(levels_in_category)+n_continuous)) = ...
            Exp_mat(ID(i), route_max+1:end-1);
        phi(1) = Exp_mat(ID(i), end);
        
        %% Gibbs sampling
        % anonymous function
        % f_err2 = @(y, mu) sum((y-mu)'*(y-mu), 1);
        f_update_phi = @(a, b) gamrnd(a, 1./b, [1, length(a)]);
        f_post_xi = @(sum_x2, prior_xi, phi) sum_x2.*phi + prior_xi;
        f_post_nu = @(post_xi, prior_xi, phi, mid, prior_nu)...
            (prior_nu.*prior_xi + mid.*phi)./post_xi;
        for t = 2: iter
            % Update nu, hyperparameter of mu_i
            post_phi = f_post_xi(vip_route(ID(i)), kappa, nu_phi);
            mid_nu = sum(mu(t,1:vip_route(ID(i))));
            post_mu = f_post_nu(post_phi, kappa, nu_phi, mid_nu, zeta);
            nu(t) = normrnd(post_mu, 1./sqrt(post_phi));
            % Update mu_i of each route
            
            alpha = y - sum(conti_mat.*repmat(mu(t-1, sum(levels_in_category)+1:end-1),N,1),2)...
                -sum(mu(t-1, categ_mat),2); 
            
            for k = 1: n_category
                alpha = alpha + mu(t-1, categ_mat(:, k));
                post_phi = f_post_xi(n_obs(sub(k)+1:sub(k+1)),nu_phi,phi(t-1)); 
                mid_categ = zeros(1, levels_in_category(k));
                for j = 1: levels_in_category(k)
                    mid_categ(j) = sum(alpha(categ_mat(:,k)==j));
                end
                post_mu = ...
                    f_post_nu(post_phi, nu_phi, phi(t-1), mid_categ, nu(t));
                mu(t, sub(k)+1:sub(k+1)) = normrnd(post_mu, 1./sqrt(post_phi));
                alpha = alpha - mu(t-1, categ_mat(:, k));
            end        
            % Update beta, coefficients of continuous predictors
            for k = 1: n_continuous
                alpha = alpha + conti_mat(:, k).*mu(t-1, sum(levels_in_category)+k) ;
                post_phi = f_post_xi(conti_mat(:,k)'*conti_mat(:,k), beta_phi, phi(t));
                mid_conti = sum(alpha, 1);
                post_mu = f_post_nu(post_phi, beta_phi, phi(t-1), mid_conti, beta_mu);
                mu(t, sum(levels_in_category)+k) = normrnd(post_mu, 1./sqrt(post_phi));
                alpha = alpha - conti_mat(:, k).*mu(t, sum(levels_in_category)+k);
            end

            mid_err = sum(alpha.^2);
            % Update phi
            phi(t) = f_update_phi(phi_a+mid_err/2, phi_b+N/2);
        end
    
        %% post Gibbs sampling selection
        Exp_mat(ID(i), [1:sum(levels_in_category),route_max+1:end-1]) = mean(mu(burnin:iter, :), 1);
        Exp_mat(ID(i), end) = mean(phi(burnin:iter, :), 1);
    end
end

