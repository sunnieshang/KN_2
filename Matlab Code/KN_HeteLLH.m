function [LLH, grad] = KN_HeteLLH(param, matrix,pred_num,choice_max, draws)
% KN_RANDOMLLH Summary of this function goes here
    ndraws = size(draws,3); nvip = size(draws,1); 
    N = size(matrix,1); par_num = length(param);
    grad = zeros(size(param,1),1); 
    
    beta_mu = param(1:pred_num); 
    gamma_mu = param(pred_num+1:pred_num+choice_max); 
    delta_mu = param(pred_num+choice_max+1);
    
    beta_sigma = exp(param(pred_num+2*choice_max+1:...
        2*pred_num+2*choice_max));
    gamma_sigma = exp(param(2*pred_num+2*choice_max+1)); 
    delta_sigma = exp(param(end)); 
    
    Pmat = zeros(nvip,ndraws); 
    Gmat = zeros(nvip,par_num);
    % draws: vip, choice_max+pred_num,draws
    % 1, trip; 2, vip; 3, choice; 4, veggieid; 5, period; 6, price; 7, fresh
    % 8. V; 9, EV; 10, sum(EV) each trip; 11, prob of each trip
    
    draws_beta = zeros(nvip,pred_num,ndraws);
    draws_gamma = zeros(nvip,choice_max+1,ndraws);
    draws_delta = zeros(nvip, choice_max, ndraws);
    for i=1:1:pred_num
        draws_beta(:,i,:) = beta_sigma(i).*draws(:,i,:) + beta_mu(i);
    end
    for i=1:1:choice_max
        draws_gamma(:,i,:) = gamma_sigma(i).*draws(:,i+pred_num,:) + gamma_mu(i);
    end
    for i = 1:1:choice_max
        draws_delta(:,i,:) = delta_sigma(i).*draws(:,i+pred_num+choice_max,:)...
            + delta_mu(i);
    end
    draws_lambda = exp(draws_delta)./(1+exp(draws_delta));
    draws_gamma(:,choice_max+1,:) = zeros(nvip,ndraws);
    visit_matsparse=sparse((1:N)',matrix(:,1),1);
    vip_matsparse=sparse((1:N)',matrix(:,2),1);
    V = zeros(N, 6); 
    for i = 1:1:ndraws 
        V(:,1) = sum(matrix(:,6:7).*draws_beta(matrix(:,2),:,i),2)+...
            draws_gamma(sub2ind(size(draws_gamma),matrix(:,2),matrix(:,4),repmat(i,N,1)));
        V(:,2) = exp(V(:,1));
        mid = visit_matsparse'*V(:,2);
        V(:,3) = mid(matrix(:,1)); 
        V(:,4) = V(:,2)./V(:,3);
        V(:, 5) = draws_lambda(matrix(:,2),:,i) .* V(:,4);
        V(2:2:end, 5) = 1 - V(1:2:end,5);
        V(:,6) = 1./V(:,5); 
        V(2:2:end,6) = -V(2:2:end,6);
        for j=1:1:nvip
            Pmat(j,i) = prod(V(matrix(:,2)==j & matrix(:,3)==1, 5));
        end
        if nargout>1 
            % beta
            for j = 1:pred_num
                Gmat(:,j) = Gmat(:,j) + Pmat(:,i).*...
                    (vip_matsparse'*(V(:,6).*matrix(:,3)...
                    .*draws_lambda(matrix(:,2),:,i).*V(:,4).*(1-V(:,4)).*kron(matrix(1:2:end,j+5),[1;1])));
            end
            % gamma
            for j=1:1:choice_max
                Gmat(:,pred_num+j) = Gmat(:,pred_num+j) + ...
                    Pmat(:,i).*(vip_matsparse'*(V(:,6).*matrix(:,3)...
                    .*draws_lambda(matrix(:,2),:,i).*V(:,4).*(1-V(:,4))));
            end
            % delta
            Gmat(:,pred_num+2*choice_max) = Gmat(:,pred_num+2*choice_max) + Pmat(:,i)...
                .*(vip_matsparse'*(V(:,6).*matrix(:,3).*kron(V(1:2:end, 4),[1;1])...
                .*draws_lambda(matrix(:,2),:,i).*(1-draws_lambda(matrix(:,2),:,i))));
            
            % beta_sigma
            for j = 1:pred_num
                Gmat(:,pred_num+2*choice_max+j) =...
                    Gmat(:,pred_num+2*choice_max+j) + ...
                    Pmat(:,i).*(vip_matsparse'*(V(:,6).*matrix(:,3)...
                    .*draws_lambda(matrix(:,2),:,i).*V(:,4).*(1-V(:,4))...
                    .*kron(matrix(1:2:end,j+5),[1;1]).*draws(matrix(:,2),j,i)*beta_sigma(j)));
            end
            % gamma_sigma
            for j=1:1:choice_max
                Gmat(:,2*pred_num+2*choice_max+j) = Gmat(:,2*pred_num+2*choice_max+j)+...
                    Pmat(:,i).*(vip_matsparse'*(V(:,6).*matrix(:,3)...
                    .*draws_lambda(matrix(:,2),:,i).*V(:,4).*(1-V(:,4)).*...
                    draws(matrix(:,2),j+pred_num,i)*gamma_sigma(j)));
            end
            % delta_sigma
            Gmat(:,end) = Gmat(:,end) + Pmat(:,i)...
                .*(vip_matsparse'*(V(:,6).*matrix(:,3).*kron(V(1:2:end, 4),[1;1])...
                .*draws_lambda(matrix(:,2),:,i).*...
                (1-draws_lambda(matrix(:,2),:,i)).*draws(matrix(:,2),pred_num+2*choice_max,i)*delta_sigma));
        end
    end
   
    LLH  =-sum(log(sum(Pmat,2))); % use sum instead of mean
    if nargout>1
        grad = -sum(Gmat./repmat(sum(Pmat,2),1,par_num), 1)';
    end

