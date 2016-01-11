function [LLH, grad] = KN_HomoLLH(param, ...
                                  ID_mat,...
                                  pred_num,...
                                  serq_num,...
                                  vip_route,...
                                  P_mat,...
                                  RMExp_mat)
%% minimize "-loglikelihood(LLH)" and recover parameters
%   Use user supplied gradient
%   LLH = sum_1^N (V_j - log(sum exp(V_j)))
    beta = param(1: pred_num + serq_num)'; 
    gamma = 0;
%     gamma   = param(end); 
%     delta   = param(end); 
%     lambda  = exp(delta) / (1 + exp(delta));
%     lambda = 1; 
    route_max = size(RMExp_mat, 2);
    nvip = length(vip_route); 
    T = size(ID_mat, 1) / nvip; 
    LLH = 0; 
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
    IndU = zeros(size(P_mat, 1), size(P_mat, 2), 2);
    IndU(:, :, 1) = KN_IndUtility(1:T*nvip, repmat(gamma,nvip,1),...
        repmat(beta, nvip, 1), RMExp_mat, P_mat, vip_route);
    IndU(:, :, 1) = exp(IndU(:, :, 1)); 
    IndU(:, :, 1) = IndU(:, :, 1) ./ (1 + IndU(:, :, 1));
    IndU(:, :, 2) = IndU(:, :, 1) .* kron(vip_route_rate, ones(T,1)); 
    LLH = LLH -sum(ID_mat(:, 7) .* log(IndU(...
        sub2ind(size(IndU), (1:nvip*T)', ID_mat(:, 3), 2 * ones(nvip*T, 1)))) ...
        + (1 - ID_mat(:, 7)) .* log(1 - sum(IndU(:, :, 2), 2)));
    
%%         Evaluate gradience
    if nargout > 1
% predictors in the column of ID_mat(T_index, 4:3+pred_num)
        for j = 1: pred_num 
            grad(j) = - sum(ID_mat(:, 7) .* (1 - ...
                IndU(sub2ind(size(IndU), (1: 1: nvip*T)', ID_mat(:, 3), 1 * ones(nvip*T, 1)))) ...
                .* ID_mat(:, 4) - ...
                (1 - ID_mat(:, 7)) ./ (1 - sum(IndU(:, :, 2), 2))...
                .* sum(IndU(:, :, 2) .* (1 - IndU(:, :, 1)) ...
                .* P_mat, 2));
        end   
        grad(pred_num + 1) = - sum(ID_mat(:, 7) .* (1 - ...
            IndU(sub2ind(size(IndU), (1: 1: nvip*T)', ID_mat(:, 3), 1 * ones(nvip*T, 1)))) ...
            .* RMExp_mat(sub2ind(size(RMExp_mat), (1: 1: nvip*T)', ID_mat(:, 3))) - ...
            (1 - ID_mat(:, 7)) ./ (1 - sum(IndU(:, :, 2), 2))...
            .* sum(IndU(:, :, 2) .* (1 - IndU(:, :, 1)).* RMExp_mat, 2));  

%         grad(end) = grad(end) - sum(ID_mat(:, 7) .* (1 - ...
%             IndU(sub2ind(size(IndU), (1: 1: nvip*T)', ID_mat(:, 3), 1 * ones(nvip*T, 1)))) - ...
%             (1 - ID_mat(:, 7)) ./ (1 - sum(IndU(:, :, 2), 2))...
%             .* sum(IndU(:, :, 2) .* (1 - IndU(:, :, 1)), 2));
                
        for j = 1: nvip
            if (j==1)
                index = pred_num + serq_num + 1;
            else 
                index = index + vip_route(j-1) - 1; 
            end
            aux = zeros(vip_route(j), T);
            aux(sub2ind(size(aux), ID_mat(T*(j-1)+1:T*j, 3), (1:T)')) = 1;
            aux = aux(2:end, :);
            grad(index: index + vip_route(j) - 2) = ...
                (repmat(vip_route_rate(j, 2:vip_route(j))', 1, T) - aux)...
                *ID_mat(T*(j-1)+1:T*j, 7) + ...
                vip_route_rate(j, 2:vip_route(j))' .* ...
                ((IndU(T*(j-1)+1:T*j, 2:vip_route(j), 1) - ...
                repmat(sum(IndU(T*(j-1)+1:T*j, :, 2), 2), 1, vip_route(j)-1))'* ...
                ((1 - ID_mat(T*(j-1)+1:T*j, 7)) ./ ...
                (1 - sum(IndU(T*(j-1)+1:T*j, :, 2), 2))));
        end   
    end  
end
    
    