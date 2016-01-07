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
    beta    = param(1: pred_num + serq_num)'; 
    gamma   = param(end); 
%     delta   = param(end); 
%     lambda  = exp(delta) / (1 + exp(delta));
%     lambda = 1; 
    route_max = max(vip_route);
    Exp_mat = KN_Exp(prior_mat, n_continuous, route_max);
    nvip    = size(Exp_mat, 1); 
    T       = size(ID_mat, 1) / nvip; 
    T_index = (0: T: T * (nvip - 1))';
    LLH     = 0; 
    vip_route_rate = zeros(nvip, route_max);
    index = pred_num + serq_num + 1;
    for i = 1: nvip
        vip_route_rate(i, 1) = 1/ ...
            (1 + sum(exp(param(index: (index+vip_route(i)-2)))));
        vip_route_rate(i, 2: vip_route(i)) = exp(param(index:index+vip_route(i)-2)) ...
            ./ (1 + sum(exp(param(index: (index+vip_route(i)-2)))));
        index = index + vip_route(i) - 1; 
    end
%     predictors updates by period
    grad = zeros(size(param, 1), 1);
%     We need a 3D matrix here (different than the simulation code) since
%     we need to write down all the possible utility of all possible routes
    IndU = zeros(nvip, route_max, 2);
    for i = 1: T 
        T_index = T_index + 1;
        IndU(:, :, 1) = KN_IndUtility(T_index, gamma, beta, Exp_mat, ID_mat);
        IndU(:, :, 1) = exp(IndU(:, :, 1)); 
        IndU(:, :, 1) = IndU(:, :, 1) ./ (1 + IndU(:, :, 1));
        IndU(:, :, 2) = IndU(:, :, 1) .* vip_route_rate; 
        LLH = LLH -sum(ID_mat(T_index, 7) .* log(IndU(...
            sub2ind(size(IndU), (1: 1: nvip)', ID_mat(T_index, 3), 2 * ones(nvip, 1)))) ...
            + (1 - ID_mat(T_index, 7)) .* log(1 - sum(IndU(:, :, 2), 2)));
%         Exp_mat = KN_BUpdate(T_index, ID_mat, prior_mat, Exp_mat, vip_route); 
%%         Evaluate gradience
        if nargout > 1
% predictors in the column of ID_mat(T_index, 4:3+pred_num)
            for j = 1: pred_num 
                grad(j) = grad(j) - sum(ID_mat(T_index, 7) .* (1 - ...
                    IndU(sub2ind(size(IndU), (1: 1: nvip)', ID_mat(T_index, 3), 1 * ones(nvip, 1)))) ...
                    .* ID_mat(T_index, 4) - ...
                    (1 - ID_mat(T_index, 7)) ./ (1 - sum(IndU(:, :, 2), 2))...
                    .* sum(IndU(:, :, 2) .* (1 - IndU(:, :, 1)) ...
                    .* repmat(ID_mat(T_index, 4), 1, route_max), 2));
            end   
            grad(pred_num + 1) = grad(pred_num + 1) - sum(ID_mat(T_index, 7) .* (1 - ...
                    IndU(sub2ind(size(IndU), (1: 1: nvip)', ID_mat(T_index, 3), 1 * ones(nvip, 1)))) ...
                    .* Exp_mat(sub2ind(size(Exp_mat), (1: 1: nvip)', ID_mat(T_index, 3))) - ...
                    (1 - ID_mat(T_index, 7)) ./ (1 - sum(IndU(:, :, 2), 2))...
                    .* sum(IndU(:, :, 2) .* (1 - IndU(:, :, 1)).* Exp_mat(:, 1:end-1), 2));  

            grad(end) = grad(end) - sum(ID_mat(T_index, 7) .* (1 - ...
                    IndU(sub2ind(size(IndU), (1: 1: nvip)', ID_mat(T_index, 3), 1 * ones(nvip, 1)))) - ...
                    (1 - ID_mat(T_index, 7)) ./ (1 - sum(IndU(:, :, 2), 2))...
                    .* sum(IndU(:, :, 2) .* (1 - IndU(:, :, 1)), 2));
                
            for j = 1: nvip
                if (j==1)
                    index = pred_num + serq_num + 1;
                else 
                    index = index + vip_route(j-1) - 1; 
                end
                aux = zeros(vip_route(j) - 1, 1);
                if(ID_mat(T_index(j), 3)-1>0)
                    aux(ID_mat(T_index(j), 3)-1) = 1;
                end
                grad(index: index + vip_route(j) - 2) = ...
                    grad(index: index + vip_route(j) - 2)...
                    - ID_mat(T_index(j), 7) * (1 - ...
                    vip_route_rate(j, ID_mat(T_index(j), 3))) * aux + ...
                    (1 - ID_mat(T_index(j), 7)) / (1 - sum(IndU(j, :, 2), 2))...
                    .* IndU(j, 2:vip_route(j), 2)' .* (1-vip_route_rate(j,2:vip_route(j)))';
            end
            i  ;   
        end        
    end   
end
    
    