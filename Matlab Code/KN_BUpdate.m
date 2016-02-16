function [MExp_mat, VExp_mat] = KN_BUpdate(T_index, ID_mat, prior_mat, MExp_mat, VExp_mat, vip_route)
% Note from Andres: need to make sure the samplers are converged
%% Parameter initialization
T_update = T_index(ID_mat(T_index, 7)==1);
if ~isempty(T_update)
    ID = ID_mat(T_update, 1); 
    iter = 1000; 
    burnin = 500; 
    route_max = max(vip_route);    
    nvip = length(vip_route);
    T = size(ID_mat, 1)/nvip;
    
    PMExp_mat = MExp_mat(ID, :);
    PVExp_mat = VExp_mat(ID, :);
    parfor i = 1: length(T_update)
        %% Priors 
        id = ID(i);
        t = mod(T_update(1), T);
        nu = zeros(iter, 1); 
        phi = zeros(iter, 1);
        zeta = prior_mat(id, 1);
        kappa = prior_mat(id, 2);
        phi_a = prior_mat(id, 3);
        phi_b = prior_mat(id, 4);
        nu_phi = prior_mat(id, 5);
        alpha_mu = prior_mat(id, 6);
        alpha_phi = prior_mat(id, 7);
        y = ID_mat(ID_mat(:, 1)==id & ID_mat(:, 7)==1 ...
            & ID_mat(:, 2) <= t, 5);
        categ_mat = ID_mat(ID_mat(:, 1) == id & ID_mat(:, 7) == 1 ...
            & ID_mat(:, 2) <= t, 3);
        conti_mat = zeros(size(categ_mat, 1), 0);
        n_category = size(categ_mat, 2);
        n_continuous = size(conti_mat, 2);
        % ID_mat: 3, route index; 4, price, 5, real experience, 7, ship or not
        levels_in_category = zeros(1, size(categ_mat, 2));
        sub = zeros(1, size(categ_mat, 2) + 1);
        levels_in_category(1) = vip_route(ID(i));
        n_obs = zeros(1, sum(levels_in_category));
        for k = 1: n_category
            if (k == 1) 
                sub(k) = 0;
            else
                sub(k) = sub(k-1)+levels_in_category(k-1);
            end
            for j = 1: levels_in_category(k)
                n_obs(sub(k) + j) = sum(categ_mat(:, k) == j);
            end
        end
        sub(end) = sub(end-1) + levels_in_category(end);
        N = length(y);
        %% Using the last expectation as starting point to reduce burnin    
        mu = zeros(iter, sum(levels_in_category)+n_continuous);
        % TODO: need to change when having multiple categorial predictors
        mid_exp = PMExp_mat(i, :);
        mid_exp1 = mid_exp(1:sum(levels_in_category));
        mid_exp2 = mid_exp(route_max + 1: end);
        mu(1, 1:sum(levels_in_category)) = mid_exp1;
        mu(1, (sum(levels_in_category) + 1): (sum(levels_in_category) + n_continuous)) = mid_exp2;
        phi(1) = PVExp_mat(i);
        
        %% Gibbs sampling
        % anonymous function
        % f_err2 = @(y, mu) sum((y-mu)'*(y-mu), 1);
        f_update_phi = @(a, b) gamrnd(a, 1./b, [1, length(a)]);
        f_post_xi = @(sum_x2, prior_xi, phi) sum_x2 .* phi + prior_xi;
        f_post_nu = @(post_xi, prior_xi, phi, mid, prior_nu)...
            (prior_nu .* prior_xi + mid .* phi) ./ post_xi;
        for t = 2: iter
            % TODO: if the # of categorial predictors increases, should
            % iterate the following part, change variables including n_obs
            % Update nu, hyperparameter of mu_i
            post_phi = f_post_xi(sum(n_obs ~= 0), kappa, nu_phi);
            mid_nu = sum(mu(t-1, n_obs ~= 0));
            post_mu = f_post_nu(post_phi, kappa, nu_phi, mid_nu, zeta);
            nu(t) = normrnd(post_mu, 1 ./ sqrt(post_phi));
            % Update mu_i of each route           
            alpha = y - sum(conti_mat.*...
                repmat(mu(t-1, (sum(levels_in_category) + 1): (end - 1)), N, 1), 2);
            for k = 1: n_category
                alpha = alpha - mu(t-1, categ_mat(:, k) + sub(k))';
            end            
            for k = 1: n_category
                alpha = alpha + mu(t-1, categ_mat(:, k) + sub(k))';               
                post_phi = f_post_xi(n_obs(sub(k) + 1: sub(k + 1)), nu_phi, phi(t-1)); 
                mid_categ = zeros(1, levels_in_category(k));
                for j = 1: levels_in_category(k)
                    mid_categ(j) = sum(alpha(categ_mat(:, k) == j));
                end
                post_mu = ...
                    f_post_nu(post_phi, nu_phi, phi(t-1), mid_categ, nu(t));
                mu(t, sub(k) + 1: sub(k + 1)) = normrnd(post_mu, 1 ./ sqrt(post_phi));
                alpha = alpha - mu(t, categ_mat(:, k) + sub(k))';
            end        
            % Update beta, coefficients of continuous predictors
            for k = 1: n_continuous
                alpha = alpha + conti_mat(:, k) * mu(t-1, sum(levels_in_category) + k) ;
                post_phi = f_post_xi(conti_mat(:, k)' * conti_mat(:, k), alpha_phi, phi(t-1));
                mid_conti = sum(alpha, 1);
                post_mu = f_post_nu(post_phi, alpha_phi, phi(t-1), mid_conti, alpha_mu);
                mu(t, sum(levels_in_category) + k) = normrnd(post_mu, 1./sqrt(post_phi));
                alpha = alpha - conti_mat(:, k) * mu(t, sum(levels_in_category) + k);
            end
            mid_err = sum(alpha.^2);
            % Update phi
            phi(t) = f_update_phi(phi_a + mid_err/2, phi_b + N/2);
        end
    
        %% post Gibbs sampling selection
        mid_exp([1: sum(levels_in_category), route_max + 1: end - 1]) = mean(mu(burnin: iter, :), 1);
        
        PMExp_mat(i, :) = mid_exp;
        PVExp_mat(i) = mean(phi(burnin: iter, :), 1);
    end
    MExp_mat(ID, :) = PMExp_mat;
    VExp_mat(ID, :) = PVExp_mat;
end
end
