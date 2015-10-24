<<<<<<< HEAD
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
=======
function Exp_mat = KN_BUpdate(T_index, ID_mat, prior_mat, Exp_mat)
    
%% Parameter initialization
    T_update  = T_index(ID_mat(T_index, 3)==1); 
    ID        = ID_mat(T_update, 1); 
    route     = pred_mat(T_update, 2);
    iter      = 1000; 
    burnin    = 500; 
    N         = length(T_update);
    route_max = size(prior_mat, 2)-5; 
    
    for i = 1:N
        %% Priors 
        zeta      = prior_mat(ID(i), route_max+1)';
        kappa     = prior_mat(ID(i), route_max+2)';
        phi_a     = prior_mat(ID(i), route_max+3)';
        phi_b     = prior_mat(ID(i), route_max+4)';
        nu_phi    = prior_mat(ID(i), route_max+5)';
  
        %% Posterior Samples
        mu        = zeros(iter, route_max); 
        nu        = zeros(iter, 1); 
        phi       = zeros(iter, 1); 
        err2      = zeros(iter, 1);
    
        %% Using the last expectation as starting point to reduce burnin
        mu(1,:)   = Exp_mat(ID(i), 1:route_max);
        phi(1)    = Exp_mat(ID(i), route_max+1);
        y         = ID_mat(T_update, 3)';
    
        %% Gibbs sampling
        for n = 1: length(ID)
            pred_cur = pred_mat(((ID(n)-1)*T, ID(n)*T-1),:);     % cur: info of the current customer
        
            %% Update coefficients of category predictors
            observation_category  =  zeros ( 1,  sum(levels_in_category));
            sum_index             =  sum   ( index,  2);
            if  n_category  >  0
                for  k  =  1:  n_category
                    for  j  =  1:  levels_in_category(k)
                        observation_category ( sub(k)+j ) = sum ( sum_index (data_info.category_predictor(:,k) == sub(k)+j ) );
                    end   
                    alpha = alpha - repmat(category(iter-1,  data_info.category_predictor(:,k))',...
                                           1,  model_setup.n_cluster-1); 
                    mid_alpha  =  sum ( index .* ( Z - alpha), 2); 
                    xi         =  post_xi  (observation_category ( sub(k)+2 : sub(k+1) ), category_xi (iter-1, k), 1);
                    mid        =  zeros (1, levels_in_category(k));
                    for  j  =  1:  levels_in_category(k)
                        mid(j)  =  sum(  mid_alpha(  data_info.category_predictor(:,k) == sub(k)+j) );
                    end
                    nu  =  post_nu( xi,  category_xi(iter-1, k), 1,  mid(2: end), prior.category_nu(sub(k)+2 : sub(k+1) ) );
                    category(iter,  sub(k)+2:  sub(k+1))  =  normrnd(nu,  1./sqrt(xi));
                    alpha  =  alpha +  repmat (category(iter,  data_info.category_predictor(:,k))',...
                                           1,  model_setup.n_cluster-1); 
                end
            end

            %% Update coefficients of continuous predictors
            if  n_continuous  >  0
                for  k  =  1:  n_continuous
                    alpha = alpha - repmat ( data_info.continuous_predictor(:,k) * ...
                                              continuous(iter-1,k),  1,  model_setup.n_cluster-1);
                    mid_alpha  =  data_info.continuous_predictor(:,k)'*sum ( index .* ( Z - alpha), 2); 
                    xi  =  post_xi (data_info.continuous_predictor(:,k)'*(data_info.continuous_predictor(:,k).*sum(index,2)),  ...
                                prior.continuous_xi,  1);
                    nu  =  post_nu (xi, prior.continuous_xi, 1, mid_alpha, prior.continuous_nu(k));
                    continuous(iter, k) = normrnd ( nu,  1./sqrt(xi) );
                    alpha  =  alpha  +  repmat ( data_info.continuous_predictor(:,k) * ...
                                              continuous(iter,k),  1,  model_setup.n_cluster-1);
                end
            end
        
        
        
            for i = 2: iter
                for j = 1: route_max
                    y_cur = pred_cur(pred_cur(:, 2)==j, 3);
                    mid_phi     = nu_phi+phi(i-1, :);
                    mid_mean    = (nu(i-1, :).*nu_phi+y.*phi(i-1, :))./mid_phi;    
                    nu(i, j)    = normrnd(mid_mean, 1./sqrt(mid_phi));
                end
                mid_phi     = kappa + nu_phi;
                mid_mean    = (zeta.*kappa + nu(i, :).*nu_phi)./mid_phi; 
                nu(i, :)    = normrnd(mid_mean, 1./sqrt(mid_phi));
                err2(i, :)  = (y-nu(i, :)).^2; 
                phi(i, :)   = gamrnd(phi_a+1/2, 1./(phi_b+1/2*err2(i, :)));        
            end
    
        %% post Gibbs sampling selection
        this_sample(:,1) = [nu(end,:), phi(end, :)];
    
        post_mat(sub2ind(size(post_mat), ID, route)) = ...
            mean(mu(burnin:iter, :), 1);
        post_mat(ID, route_max+1) = mean(nu(burnin:iter, :), 1);
        post_mat(ID, route_max+2) = kappa + nu_phi;
        post_mat(ID, route_max+3) = phi_a + 1/2;
        post_mat(ID, route_max+4) = phi_b + 1/2*mean(err2, 1);
        post_mat(ID, route_max+5) = nu_phi + mean(phi(burnin:iter, :), 1);
    
        end
>>>>>>> 583e2e3e23b6f089c3245f838428846cd603a7a2
    end
end

