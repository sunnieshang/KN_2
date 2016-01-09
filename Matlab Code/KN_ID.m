function [ID_mat, P_mat, S_mat] = KN_ID(vip_route_rate, T, vip_route)
    nvip = size(vip_route_rate, 1); 
    ID_mat = zeros(nvip*T, 7);
    ID_mat(:, 1) = kron((1: nvip)', ones(T, 1));
    ID_mat(:, 2) = repmat((1: T)', nvip, 1);
    route_max = size(vip_route_rate, 2);
    P_mat = zeros(nvip*T, route_max);
    S_mat = zeros(nvip*T, route_max);
    for i=1:nvip
        ID_mat((i-1)*T+1: i*T, 3) = sum(mnrnd(ones(T, 1), vip_route_rate(i, :)) ...
            .* repmat(1:1:route_max, T, 1), 2);
        P_mat((i-1)*T+1: i*T, 1:vip_route(i)) = ...
            exp(normrnd(0, 1, [T, vip_route(i)])); % price 
        S_mat((i-1)*T+1: i*T, 1:vip_route(i)) = ...
            normrnd(-8, 16, [T, vip_route(i)]); % real experience
    end 
    ID_mat(:, 4) = P_mat(sub2ind(size(P_mat), (1:nvip*T)', ID_mat(:,3)));    
    ID_mat(:, 5) = S_mat(sub2ind(size(S_mat), (1:nvip*T)', ID_mat(:,3)));
end

