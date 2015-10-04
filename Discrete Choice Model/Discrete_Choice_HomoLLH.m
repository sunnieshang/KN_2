function [LLH, grad] = Discrete_Choice_HomoLLH(param, matrix,pred_num,veggie_max)
% minimize "-loglikelihood(LLH)" and recover parameters
%   Use user supplied gradient
%   LLH = sum_1^N (V_j - log(sum exp(V_j)))
% 1, trip; 2, vip; 3, choice; 4, veggieid; 5, period; 6, price; 7, fresh
% 8. V; 9, EV; 10, sum(EV) each trip; 11, prob of each trip
    beta = param(1:pred_num); 
    gamma = [param(pred_num+1:pred_num+veggie_max);0]; 
    V = zeros(size(matrix,1),4); 
    V(:,1) = gamma(matrix(:,4)) + matrix(:,6:7)*beta;
    V(:,2) = exp(V(:,1));
    visit_matsparse=sparse((1:size(V,1))',matrix(:,1),1);
    mid = visit_matsparse'*V(:,2);
    V(:,3) = mid(matrix(:,1));
	V(:,4) = V(:,2)./V(:,3);
    LLH = -sum(matrix(:,3).*log(V(:,4)));
    
    %% Evaluate the gradient
    if nargout>1
        grad = zeros(pred_num+veggie_max,1);
        grad(1:pred_num) = sum(-matrix(:,6:7).*repmat(matrix(:,3),1,pred_num)+...
            matrix(:,6:7).*repmat(V(:,2),1,pred_num)./repmat(V(:,3),1,pred_num),1);
        for i=1:1:veggie_max
            grad(i+2) = sum(-matrix(matrix(:,4)==i,3)+V(matrix(:,4)==i,4));
        end
    end
end

