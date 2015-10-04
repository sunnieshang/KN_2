function [prior] = KN_Prior(vip_route, n_continuous)
    nvip = size(vip_route,1); max_route = max(vip_route);
    prior = zeros(nvip, max(vip_route)+5+2*n_continuous);

    
    prior(:,max_route+2) = 1; prior(:,max_route+3) = 1; 
    prior(:,max_route+4) = 1; prior(:,max_route+5) = 1;
    for i = 1:n_continuous
        prior(:,max_route+4+i*2) = 0; 
        prior(:,max_route+5+i*2) = 1; 
    end
end