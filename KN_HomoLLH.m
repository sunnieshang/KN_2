function [LLH, grad] = KN_HomoLLH(param, ...
                                  ID_mat,...
                                  prior_mat,...
                                  pred_num,...
                                  serq_num,...
                                  n_continuous,...
                                  vip_route)
%% minimize "-loglikelihood(LLH)" and recover parameters
%   Use user supplied gradient
%   LLH = sum_1^N (V_j - log(sum exp(V_j)))
    BExpect = ID_mat(:, 6); 
    beta    = param(1: pred_num + serq_num)'; 
    gamma   = param(pred_num + serq_num + 1); 
    delta   = param(end); 
    lambda  = exp(delta) / (1 + exp(delta));
    route_max = max(vip_route);
    Exp_mat = KN_Exp(prior_mat, n_continuous, route_max);
    nvip    = size(Exp_mat, 1); 
    T       = size(ID_mat, 1) / nvip;
    V       = zeros(nvip, 4); 
    T_index = (0: T: T * (nvip - 1))';
    LLH     = 0; 
    % predictors updates by period
    for i = 1: T 
        T_index = T_index + 1;
        V(:, 1) = KN_IndUtility(T_index, gamma, repmat(beta, nvip, 1), ID_mat);
        V(:, 2) = exp(V(:, 1));
        V(:, 3) = V(:, 2) ./ (V(:, 2) + 1);
        V(:, 4) = lambda .* V(:, 3);
        Exp_mat = KN_BUpdate(T_index, ID_mat, prior_mat, Exp_mat, vip_route); 
        if i<T
            BExpect(T_index + 1, 6) = Exp_mat(...
                sub2ind(size(Exp_mat), (1: 1: nvip)', ID_mat(T_index + 1, 3)));
        end
        LLH = LLH -sum(ID_mat(T_index, 7) .* log(V(:, 4)) + ...
            (1 - ID_mat(T_index, 7)) .* log(1 - V(:, 4)));
    end
    
    
    %% Evaluate the gradient
    if nargout > 1
        grad = zeros(pred_num + serq_num + 2, 1);
        % beta
        for i = 1: pred_num
            grad(i) = -sum((ID_mat(:, 7) ./ V(:, 4) - ...
                (1 - ID_mat(:, 7)) ./ (1 - V(:, 4)))...
                .* V(:, 4) .* (1 - V(:, 3)) .* ID_mat(:, i + 3));
        end   
        grad(i) = -sum((ID_mat(:, 7) ./ V(:, 4) - ...
                (1 - ID_mat(:, 7)) ./ (1 - V(:, 4)))...
                .* V(:, 4) .* (1 - V(:, 3)) .* BExpect);  
        % Grad(gamma) = sum{[y/(1+ev)-lambda*ev/(1+ev)^2]/[1-lambda*ev/(1+ev)]}
        grad(1 + pred_num + serq_num) = -sum((ID_mat(:, 7) ./ V(:, 4) - ...
                (1 - ID_mat(:, 7)) ./ (1 - V(:, 4)))...
                .* V(:, 4) .* (1 - V(:, 3))) ;
        % delta
        grad(end) = -sum((ID_mat(:, 7) ./ V(:, 4) - ...
                (1 - ID_mat(:, 7)) ./ (1 - V(:, 4)))...
                .* V(:, 4) .* (1 - lambda));
    end
end

