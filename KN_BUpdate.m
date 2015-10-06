function Exp_mat = KN_BUpdate(T_index, ID_mat, prior_mat)
    %% Parameter initialization
    post_mat  = prior_mat;
    T_update  = T_index(ID_mat(T_index, 3)==1); 
    ID        = ID_mat(T_update, 1); 
    route     = pred_mat(T_update, 2);
    iter      = 1000; 
    burnin    = 500; 
 
    %% Priors 
    zeta      = prior_mat(ID, route_max+1)';
    kappa     = prior_mat(ID, route_max+2)';
    phi_a     = prior_mat(ID, route_max+3)';
    phi_b     = prior_mat(ID, route_max+4)';
    nu_phi    = prior_mat(ID, route_max+5)';
  
    %% Posterior Samples
    mu        = zeros(iter, length(T_update)); 
    nu        = zeros(iter, length(T_update)); 
    phi       = zeros(iter, length(T_update)); 
    err2      = zeros(iter, length(T_update));
    
    %% TODO: change the starting point as old info
    nu(1,:)   = last_sample(ID, 1);
    phi(1,:)  = last_sample(ID, 2);
    y         = pred_mat(T_update, 3)';
    
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

