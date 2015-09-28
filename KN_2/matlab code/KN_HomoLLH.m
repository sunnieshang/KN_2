function [LLH, grad] = KN_HomoLLH(param, ID_matrix,data_predictor,post_matrix,pred_num,serq_num, route_max)
% minimize "-loglikelihood(LLH)" and recover parameters
%   Use user supplied gradient
%   LLH = sum_1^N (V_j - log(sum exp(V_j)))
% 1, trip; 2, vip; 3, choice; 4, veggieid; 5, period; 6, price; 7, fresh
% 8. V; 9, EV; 10, sum(EV) each trip; 11, prob of each trip
    beta = param(1:pred_num+serq_num)'; 
    gamma = param(pred_num+serq_num+1); 
    delta = param(end); lambda = exp(delta)/(1+exp(delta));
    nvip = size(post_matrix,1); T = size(ID_matrix,1)/nvip;
    V = zeros(nvip*T,4); 
    T_index = (0:T:T*(nvip-1))';
    % predictors updates by period
    for i = 1:T
        T_index = T_index+1;
        V(T_index,1) = KN_IndUtility(T_index,ID_matrix,gamma,beta,data_predictor,post_matrix);
        V(T_index,2) = exp(V(T_index,1));
        V(T_index,3) = V(T_index,2)./(V(T_index,2)+1);
        V(T_index,4) = lambda .* V(T_index,3);
        prior_matrix = post_matrix;
        post_matrix = KN_BUpdate(T_index,ID_matrix,data_predictor,prior_matrix,route_max);
    end
    LLH = -sum(ID_matrix(:,3).*log(V(:,4))+(1-ID_matrix(:,3)).*log(1-V(:,4)));
    
    %% Evaluate the gradient
    if nargout>1
        grad = zeros(pred_num+serq_num+2,1);
        % beta
        for i = 1:pred_num
            grad(i) = -sum((ID_matrix(:,3)./V(:,4)-(1-ID_matrix(:,3))./(1-V(:,4)))...
                .*lambda.*V(:,3).*(1-V(:,3)).*data_predictor(:,i+3));
        end
        grad(pred_num+1) = -sum((ID_matrix(:,3)./V(:,4)-(1-ID_matrix(:,3))./(1-V(:,4)))...
                .*lambda.*V(:,3).*(1-V(:,3)).*post_matrix(sub2ind(size(post_matrix),...
                ID_matrix(:,2),data_predictor(:,2))));
       
        % gamma
        grad(1+pred_num+serq_num) = -sum((ID_matrix(:,3)./V(:,4)-(1-ID_matrix(:,3))./(1-V(:,4)))...
            .*lambda.*V(:,3).*(1-V(:,3)));
        % delta
        grad(end) = -sum((ID_matrix(:,3)./V(:,4)-(1-ID_matrix(:,3))./(1-V(:,4)))...
            .*V(:,3).*lambda.*(1-lambda));
    end
end

