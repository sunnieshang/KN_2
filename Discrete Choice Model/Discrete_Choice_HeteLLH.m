function [LLH, grad] = Discrete_Choice_HeteLLH(param, matrix,pred_num,veggie_max, draws)
% KN_RANDOMLLH Summary of this function goes here
    ndraws = size(draws,3); nvip = size(draws,1); 
    N = size(matrix,1); par_num = length(param);
    grad = zeros(size(param,1),1); beta_mu = param(1:pred_num); 
    beta_sigma = param(pred_num+veggie_max+1:pred_num+veggie_max+pred_num);
    gamma_mu = param(pred_num+1:pred_num+veggie_max); 
    gamma_sigma = param(end); Pmat=zeros(nvip,ndraws); Gmat=zeros(nvip,par_num);
    % draws: vip, veggie_max+pred_num,draws
    % 1, trip; 2, vip; 3, choice; 4, veggieid; 5, period; 6, price; 7, fresh
    % 8. V; 9, EV; 10, sum(EV) each trip; 11, prob of each trip
    
    draws_beta = zeros(nvip,pred_num,ndraws);
    draws_gamma = zeros(nvip,veggie_max+1,ndraws);
    for i=1:1:pred_num
        draws_beta(:,i,:) = beta_sigma(i).*draws(:,i,:)+beta_mu(i);
    end
    for i=1:1:veggie_max
        draws_gamma(:,i,:) = gamma_sigma.*draws(:,i+pred_num,:)+gamma_mu(i);
    end
    draws_gamma(:,veggie_max+1,:) = zeros(nvip,ndraws);
    visit_matsparse=sparse((1:N)',matrix(:,1),1);
    V = zeros(N,4); 
    for i = 1:1:ndraws 
        V(:,1) = sum(matrix(:,6:7).*draws_beta(matrix(:,2),:,i),2)+...
            draws_gamma(sub2ind(size(draws_gamma),matrix(:,2),matrix(:,4),repmat(i,N,1)));
        V(:,2) = exp(V(:,1));
        mid = visit_matsparse'*V(:,2);
        V(:,3) = mid(matrix(:,1)); V(:,4) = V(:,2)./V(:,3);
        for j=1:1:nvip
            Pmat(j,i) = prod(V(matrix(:,2)==vip & matrix(:,3)==1, 4));
        end
        % derivatives
        if nargout>1,
            localmeanxp = visit_matsparse'*(repmat(Pmat(:,i),1,pred_num).*...
                matrix(:,6:7));
            % mean terms (derivatives of the drawn parameter with respect to the
            % mean is just 1)
            Gmat(:,1:pred_num) = Gmat(:,1:pred_num) + repmat(Pmat(:,i),1,2).*...
                (matrix(:,6:7)- localmeanxp(matrix(:,1),:));
            for j=1:1:veggie_max
                Gmat(:,pred_num+j) = Gmat(:,pred_num+j) + ...
                Pmat(:,i).*(1- Pmat(:,i)).*(matrix(:,4)==j);
            end
            % std. deviation terms (derivative of the drawn parameter with respect
            % to the std parameter is just equal to the draw itself)
            Gmat(:,pred_num+veggie_max+1:2*pred_num+veggie_max) =...
                Gmat(:,pred_num+veggie_max+1:2*pred_num+veggie_max) + ...
                repmat(Pmat(:,i),1,2).*draws(matrix(:,2),1:pred_num,i).*...
                (matrix(:,6:7)-localmeanxp(matrix(:,1),:));  
            for j=1:1:veggie_max
                Gmat(:, end) = Gmat(:,end)+Pmat(:,i).*...
                    draws(matrix(:,2),pred_num+j,i).*(1 - Pmat(:,i)).*(matrix(:,4)==j);
            end
        end
    end
   
    P = mean(Pmat,2);
    LLH  =-sum(matrix(:,3).*log(P));
    if nargout>1
        grad = -sum(repmat(matrix(:,3),1,size(Gmat,2)).*...
            (Gmat./repmat(sum(Pmat,2),1,size(Gmat,2))))';
    end

