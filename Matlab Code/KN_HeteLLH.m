function [LLH, grad] = KN_HeteLLH(...
    param, Start_mat, pred_num, hete_num, vip_route, X, draws)
    
    ndraws = size(draws, 3); 
    beta_mu = param(1: pred_num)'; 
    beta_sigma = exp(param(end-hete_num+1 : end));
    route_max = max(vip_route);
    nvip = length(vip_route); 
    T = size(Start_mat, 1) / nvip; 
    vip_route_rate = zeros(nvip, route_max);
    index1 = pred_num + 1;
    for i = 1: nvip
        vip_route_rate(i, 1) = 1/ ...
            (1 + sum(exp(param(index1: (index1+vip_route(i)-2)))));
        vip_route_rate(i, 2: vip_route(i)) = exp(param(index1: index1+vip_route(i)-2)) ...
            ./ (1 + sum(exp(param(index1: (index1+vip_route(i)-2)))));
        index1 = index1 + vip_route(i) - 1; 
    end
    draws_beta = zeros(size(draws, 1), pred_num, size(draws, 3));
    for i = 1: hete_num
        draws_beta(:, i, :) = beta_sigma(i) .* draws(:, i, :) + beta_mu(i);
    end
    for i = hete_num + 1: pred_num
        draws_beta(:, i, :) = beta_mu(i);
    end
    IndU = zeros(size(X, 1), route_max, 2);
    P_IR = zeros(nvip, ndraws); 
    GG = zeros(nvip, length(param));
    grad = zeros(length(param), 1);
    mid_mat = kron(eye(nvip), ones(T, 1))';
    
    for i = 1: ndraws           
%     We need a 3D matrix here (different than the simulation code) since
%     we need to write down all the possible utility of all possible routes
        IndU(:, :, 1) = KN_IndUtility(1: T*nvip, draws_beta(:, :, i), X, vip_route);
        IndU(:, :, 1) = exp(IndU(:, :, 1)); 
        IndU(:, :, 1) = IndU(:, :, 1) ./ (1 + IndU(:, :, 1));
        IndU(:, :, 2) = IndU(:, :, 1) .* kron(vip_route_rate, ones(T, 1)); 
        logP = Start_mat(:, end) .* log(IndU(sub2ind(size(IndU), ...
            (1: nvip*T)', Start_mat(:, 3), 2 * ones(nvip*T, 1)))) ...
            + (1 - Start_mat(:, end)) .* log(1 - sum(IndU(:, :, 2), 2));           
        P_IR(:, i) = exp(mid_mat * logP);
        
        if nargout > 1 
            for j = 1: pred_num
                GG(:, j) = GG(:, j) + P_IR(:, i).*(mid_mat * (Start_mat(:, end) .* (1 - ...
                IndU(sub2ind(size(IndU), (1: 1: nvip*T)', Start_mat(:, 3), 1 * ones(nvip*T, 1)))) ...
                .* X(sub2ind(size(X), (1: 1: nvip*T)', Start_mat(:, 3), j*ones(nvip*T,1)))...
                - (1 - Start_mat(:, end)) ./ (1 - sum(IndU(:, :, 2), 2))...
                .* sum(IndU(:, :, 2) .* (1 - IndU(:, :, 1)) .* X(:,:,j), 2)));
            end     
            for j = 1: nvip
                if (j==1)
                    index = pred_num + 1;
                else 
                    index = index + vip_route(j-1) - 1; 
                end
                aux = zeros(vip_route(j), T);
                aux(sub2ind(size(aux), Start_mat(T*(j-1)+1:T*j, 3), (1:T)')) = 1;
                aux = aux(2:end, :);
                GG(j, index: index + vip_route(j) - 2) = ...
                    GG(j, index: index + vip_route(j) - 2) - ...
                    P_IR(j, i)*((repmat(vip_route_rate(j, 2:vip_route(j))', 1, T) - aux)...
                    *Start_mat(T*(j-1)+1:T*j, end) + ...
                    vip_route_rate(j, 2:vip_route(j))' .* ...
                    ((IndU(T*(j-1)+1:T*j, 2:vip_route(j), 1) - ...
                    repmat(sum(IndU(T*(j-1)+1:T*j, :, 2), 2), 1, vip_route(j)-1))'* ...
                    ((1 - Start_mat(T*(j-1)+1:T*j, end)) ./ ...
                    (1 - sum(IndU(T*(j-1)+1:T*j, :, 2), 2)))))';
            end 
            for j = 1: hete_num
                GG(:, end-hete_num+j) = GG(:, end-hete_num+j) + P_IR(:, i).*(mid_mat * (Start_mat(:, end) .* (1 - ...
                    IndU(sub2ind(size(IndU), (1: 1: nvip*T)', Start_mat(:, 3), 1 * ones(nvip*T, 1)))) ...
                    .* X(sub2ind(size(X), (1: 1: nvip*T)', Start_mat(:, 3), j*ones(nvip*T,1)))...
                    - (1 - Start_mat(:, end)) ./ (1 - sum(IndU(:, :, 2), 2))...
                    .* sum(IndU(:, :, 2) .* (1 - IndU(:, :, 1)) .* X(:,:,j) ...
                    , 2))) .* draws(:, j, i) .* beta_sigma(j);
            end
        end
    end
   
    LLH  = -sum(log(mean(P_IR, 2)));
    if nargout > 1
        grad = -sum(GG./repmat(sum(P_IR, 2), 1, length(param)), 1)';
    end
end