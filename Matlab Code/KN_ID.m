function [ID_mat] = KN_ID(vip_route_rate, T)
    nvip = size(vip_route_rate, 1); 
    ID_mat = zeros(nvip*T, 7);
    ID_mat(:, 1) = kron((1: nvip)', ones(T, 1));
    ID_mat(:, 2) = repmat((1: T)', nvip, 1);
    route_max = size(vip_route_rate, 2);
    for i=1:nvip
        ID_mat((i-1)*T+1: i*T, 3) = sum(mnrnd(ones(T, 1), vip_route_rate(i, :)) ...
            .* repmat(1:1:route_max, T, 1), 2);
    end
    ID_mat(:, 4) = exp(normrnd(0, 1, [nvip*T, 1])); % price  
    ID_mat(:, 5) = normrnd(-8, 16, [nvip*T, 1]);  % real experience
end

