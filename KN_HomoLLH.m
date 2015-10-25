function [LLH, grad] = KN_HomoLLH(param, ...
                                  ID_mat,...
                                  prior_mat,...
                                  pred_num,...
                                  serq_num,...
                                  n_continuous,...
                                  route_max)
%% minimize "-loglikelihood(LLH)" and recover parameters
%   Use user supplied gradient
%   LLH = sum_1^N (V_j - log(sum exp(V_j)))
    beta    = param(1: pred_num + serq_num)'; 
    gamma   = param(pred_num + serq_num + 1); 
    delta   = param(end); 
    lambda  = exp(delta) / (1 + exp(delta));
    Exp_mat = KN_Exp(prior_mat, n_continuous, route_max);
    nvip    = size(Exp_mat, 1); 
    T       = size(ID_mat, 1) / nvip;
    V       = zeros(nvip * T, 4); 
    T_index = (0: T: T * (nvip - 1))';
    % predictors updates by period
    for i = 1: T 
        T_index = T_index + 1;
        V(T_index, 1) = KN_IndUtility(T_index, gamma, beta, ID_mat);
        V(T_index, 2) = exp(V(T_index, 1));
        V(T_index, 3) = V(T_index, 2) ./ (V(T_index, 2) + 1);
        V(T_index, 4) = lambda .* V(T_index, 3);
        Exp_mat = KN_BUpdate(T_index, ID_mat, prior_mat, Exp_mat, vip_route); 
        if t<T
            ID_mat(T_index + 1, 6) = Exp_mat(...
                sub2ind(size(Exp_mat), (1: 1: nvip)', ID_mat(T_index + 1, 3)));
        end
    end
    LLH = -sum(ID_mat(:, 7) .* log(V(:, 4)) + (1 - ID_mat(:, 7)) .* log(1 - V(:, 4)));
    
    %% Evaluate the gradient
    if nargout>1
        grad = zeros(pred_num + serq_num + 2, 1);
        % beta
        for i = 1: pred_num
            grad(i) = -sum((ID_mat(:, 7) ./ V(:, 4) - ...
                (1 - ID_mat(:, 7)) ./ (1 - V(:, 4)))...
                .* lambda .* V(:, 3) .* (1 - V(:, 3)) .* Exp_mat(:, i+3));
        end
        grad(pred_num + 1) = -sum((ID_mat(:, 3) ./ V(:, 4) - ...
            (1 - ID_mat(:, 3)) ./ (1 - V(:, 4))) .* lambda .* V(:, 3)...
            .* (1 - V(:, 3)) .* post_matrix(sub2ind(size(post_matrix),...
                ID_mat(:, 2), Exp_mat(:, 2))));
       
        % gamma
        grad(1 + pred_num + serq_num) = -sum((ID_mat(:, 3) ./ V(:, 4) - ...
            (1 - ID_mat(:, 3)) ./ (1 - V(:, 4)))...
            .* lambda .* V(:, 3) .* (1 - V(:, 3)));
        % delta
        grad(end) = -sum((ID_mat(:, 3) ./ V(:, 4) - (1 - ID_mat(:, 3))...
            ./ (1 - V(:, 4))) .* V(:, 3) .* lambda .* (1 - lambda));
    end
end

