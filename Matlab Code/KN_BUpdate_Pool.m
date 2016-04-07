function [MExp_mat, ...
          VExp_mat, ...
          NPrior_mat, ...
          MExp_mat_95, ...
          VExp_mat_95, LL, DIC] = KN_BUpdate_Pool(T_index, ...
                                    Complete_mat, ...
                                    Prior_mat, ...
                                    MExp_mat, ...
                                    VExp_mat, ...
                                    Vip_route, ...
                                    NPrior_mat, ...
                                    MExp_mat_95, ...
                                    VExp_mat_95)
% Note from Andres: need to make sure the samplers are converged
%% Parameter initialization
ID = unique(Complete_mat(Complete_mat(:, 2)==T_index(1), 1));
LL = 0; DIC = 0;
if ~isempty(ID)
    iter = 1000; 
    burnin = 500; 
    route_max = max(Vip_route);    
%     nvip = length(Vip_route);
%     T = size(Complete_mat, 1)/nvip;   
    PMExp_mat = MExp_mat(ID, :);
    PVExp_mat = VExp_mat(ID, :);
    PNPrior_mat = NPrior_mat(ID, :);
    nLL = zeros(length(ID), 1);
    nDIC = zeros(length(ID), 1);
    parfor i = 1: length(ID)
        %% Priors 
        id = ID(i);
        t = T_index(1);
        nu = zeros(iter, 1); 
        phi = zeros(iter, 1);
        nu_phi = zeros(iter, 1);
        zeta = Prior_mat(id, 1);
        n_zeta = zeros(iter, 1);
        kappa = Prior_mat(id, 2);
        n_kappa = zeros(iter, 1);
        phi_a = Prior_mat(id, 3);
        n_phi_a = zeros(iter, 1);
        phi_b = Prior_mat(id, 4);
        n_phi_b = zeros(iter, 1);
        nu_phi_a = Prior_mat(id, 5);
        nu_phi_b = Prior_mat(id, 6); 
        n_nu_phi_a = zeros(iter, 1);    
        n_nu_phi_b = zeros(iter, 1); 
        categ_mat = Complete_mat(Complete_mat(:, 1) == id & Complete_mat(:, 2) <= t, 3);
        y = Complete_mat(Complete_mat(:, 1)==id & Complete_mat(:, 2) <= t, 4);
        n_continuous = 0;
        if size(Prior_mat, 2)>6
            alpha_mu = Prior_mat(id, 7);
            n_alpha_mu = zeros(iter, 1);
            alpha_phi = Prior_mat(id, 8);
            n_alpha_phi = zeros(iter, 1);
            conti_mat = Complete_mat(Complete_mat(:, 1)==id & Complete_mat(:, 2) <= t, 5);
            n_continuous = 1;
        end       
%         n_obs = zeros(1, Vip_route(ID(i)));
%         for j = 1: Vip_route(ID(i))
%             n_obs(j) = sum(categ_mat == j);
%         end
        N = length(y);
        %% Using the last expectation as starting point to reduce burnin    
        mu = zeros(iter, Vip_route(ID(i)) + n_continuous);
        % TODO: need to change when having multiple categorial predictors
        mid_exp = PMExp_mat(i, :);
        mid_exp_95 = zeros(1, length(mid_exp)*2);
        mid_exp1 = mid_exp(1: Vip_route(ID(i)));
        mid_exp2 = mid_exp(route_max + 1: end);
        mu(1, 1: Vip_route(ID(i))) = mid_exp1;
        mu(1, Vip_route(ID(i))+1:Vip_route(ID(i))+n_continuous) = mid_exp2(1);
        mid = PVExp_mat(i, :);
        phi(1) = mid(1);
        nu_phi(1) = mid(2);
        
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
%             n_kappa(t) = f_post_xi(sum(n_obs ~= 0), kappa, nu_phi(t-1));
%             mid_nu = sum(mu(t-1, 1: end-n_continuous).*(n_obs>0));
%             n_zeta(t) = f_post_nu(n_kappa(t), kappa, nu_phi(t-1), mid_nu, zeta);
%             nu(t) = normrnd(n_zeta(t), 1 ./ sqrt(n_kappa(t))); % updates of the parameters of focal interests
            
            % Update nu_phi (xi in the paper)
%             mid_nu = nu(t) - mu(t-1, 1: Vip_route(ID(i)));
%             mid_nu = mid_nu .* (n_obs>0);
%             n_nu_phi_a(t) = nu_phi_a + sum(n_obs>0)/2;
%             n_nu_phi_b(t) = nu_phi_b + sum(mid_nu.^2)/2; 
%             nu_phi(t) = f_update_phi(n_nu_phi_a(t), n_nu_phi_b(t));
                        
            % Update mu_i of each route   
            if n_continuous > 0
                alpha = y - conti_mat.*mu(t-1, end);
            else
                alpha = y;
            end              
            post_phi = f_post_xi(N, kappa, phi(t-1)); 
%             mid_categ = zeros(1, Vip_route(ID(i)));
%             for j = 1: Vip_route(ID(i))
%                 mid_categ(j) = sum(alpha(categ_mat == j));
%             end
            post_mu = ...
                f_post_nu(post_phi, kappa, phi(t-1), sum(alpha), zeta);
            mu(t, 1: Vip_route(ID(i))) = repmat(normrnd(post_mu, 1 ./ sqrt(post_phi)), 1, Vip_route(ID(i)));
            n_zeta(t) = post_mu;
            n_kappa(t) = post_phi;
            alpha = y - mu(t, categ_mat)';  

            % Update beta, coefficients of continuous predictors
            if n_continuous > 0
                post_phi = f_post_xi(conti_mat' * conti_mat, alpha_phi, phi(t-1));
                mid_conti = sum(alpha, 1);
                post_mu = f_post_nu(post_phi, alpha_phi, phi(t-1), mid_conti, alpha_mu);
                n_alpha_mu(t) = post_mu;
                n_alpha_phi(t) = post_phi;
                mu(t, end) = normrnd(post_mu, 1./sqrt(post_phi));
                alpha = alpha - conti_mat * mu(t, end);
            end
            mid_err = sum(alpha.^2);
            % Update phi            
            n_phi_a(t) = phi_a + N/2;
            n_phi_b(t) = phi_b + mid_err/2; 
            phi(t) = f_update_phi(n_phi_a(t), n_phi_b(t));
        end
    
        %% post Gibbs sampling selection
        mid_mat = [mu, nu];
        mid_exp([1: Vip_route(ID(i)), end-n_continuous:end]) = mean(mid_mat(burnin: iter, :), 1);
        % PNPrior_mat(i, :) = ; 
        PMExp_mat(i, :) = mid_exp;
        mid = quantile(mid_mat(burnin: iter, :), [0.05, 0.95]);
        mid = reshape(mid, 1, size(mid,1)*size(mid,2));
        mid_exp_95([1: 2*Vip_route(ID(i)), end-1-2*n_continuous: end]) = mid;
        PMExp_mat_95(i, :) = mid_exp_95; 
        
        mid_mat = [phi nu_phi];
        mid = mean(mid_mat(burnin: iter, :), 1);
        PVExp_mat(i, :) = mid;       
        mid = quantile(mid_mat(burnin: iter, :), [0.05, 0.95]);
        mid = reshape(mid, 1, size(mid,1)*size(mid,2));
        PVExp_mat_95(i, :) = mid;
        if n_continuous > 0
            mid = [n_zeta n_kappa n_phi_a n_phi_b n_nu_phi_a n_nu_phi_b ...
                n_alpha_mu n_alpha_phi];
        else 
            mid = [n_zeta n_kappa n_phi_a n_phi_b n_nu_phi_a n_nu_phi_b];
        end
        PNPrior_mat(i, :) = mean(mid(burnin: iter, :), 1);
        
        %% Calculate this period log-likelihood 
        categ_mat = Complete_mat(Complete_mat(:, 1) == id & Complete_mat(:, 2) == T_index(1), 3);
        y = Complete_mat(Complete_mat(:, 1)==id & Complete_mat(:, 2) == T_index(1), 4);
        if n_continuous == 0
            for p = 1: length(y)
                nLL(i) = nLL(i) + mean(log(normpdf(y(p), mu(burnin:iter, categ_mat(p)), ...
                    1./sqrt(phi(burnin:iter)))));
                nDIC(i) = nDIC(i) - 4*nLL(i) + 2*log(normpdf(y(p), mean(mu(burnin:iter, categ_mat(p))), ...
                    1/sqrt(mean(phi(burnin:iter)))));
            end
        else 
            conti_mat = Complete_mat(Complete_mat(:, 1)==id & Complete_mat(:, 2) == T_index(1), 5);
            for p = 1: length(y)
                nLL(i) = nLL(i) + mean(log(normpdf(y(p), mu(burnin:iter, categ_mat(p)) + conti_mat(p)*mu(burnin:iter, end), ...
                    1./sqrt(phi(burnin:iter)))));
                nDIC(i) = nDIC(i) - 4*nLL(i) + 2*log(normpdf(y(p), mean(mu(burnin:iter, categ_mat(p)) + conti_mat(p)*mu(burnin:iter, end)), ...
                    1./sqrt(mean(phi(burnin:iter)))));
            end
        end  
    end
    LL = LL + sum(nLL); 
    DIC = DIC + sum(nDIC);
    MExp_mat(ID, :) = PMExp_mat;
    VExp_mat(ID, :) = PVExp_mat;
    NPrior_mat(ID, :) = PNPrior_mat; 
    MExp_mat_95(ID, :) = PMExp_mat_95;
    VExp_mat_95(ID, :) = PVExp_mat_95;
end
end
