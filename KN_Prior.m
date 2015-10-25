function [prior] = KN_Prior(n_continuous, nvip)
    prior = zeros(nvip, 5+2*n_continuous); 
    prior(:,2) = 0.1; prior(:,3) = 1; 
    prior(:,4) = 1/0.2; prior(:,5) = 0.1;
    prior(:,7) = 0.1; 
end